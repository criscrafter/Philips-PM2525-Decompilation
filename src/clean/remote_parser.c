/* remote_parser.c (hand-cleaned) - remote command parser (firmware S25)
 *
 * Original: hand-written assembly state machine at 0x77B6-0x7BCC, run one character per main-loop
 * pass by task_remote_parse (0x543C). This C version implements the same grammar and produces the
 * same tokens; the behaviour was established by running the original parser in the emulator on the
 * whole command table and on mixed inputs (tools/parse_cmd.py, see DECOMPILATION.md "Remote commands").
 *
 * Input: one line in XDATA iface_rx_buf (0x0013), rx_count (IRAM 0Dh) = bit 7 line present,
 *        bit 6 end of message, bits 0-5 characters left; rx_index (0Ch) = read position.
 * Output: a token in the parser context (IRAM 2Ah-36h, saved at XDATA 0x00DB); the parser then waits
 *        until the executor (fnsel_dispatch in task_keyboard) has consumed it (flags bit 7 cleared).
 *
 * Grammar (verified: tools/check_parser.py compares this logic with the original on 721 inputs, 0 differ):
 *   line     = command { (";" | ",") command }   ',' starts a new command unless the command takes a
 *                                                 second parameter (type bit 6). So "TRG B,X" = TRG B; X
 *   command  = name [ param [ "," param ] ]
 *   name     = letters; matched against cmd_table, where a blank in the table name matches anything
 *              ("XYZ" is accepted as X, "CRX" as CR)
 *   param, tried in this order, each only if the command's type byte allows it:
 *     "?"                      bit 5 query (else a word "?" if bit 4, else the command is dropped)
 *     ON | OFF                 bit 0
 *     integer 0..255           bit 1 (only plain digits <= 255 if bit 3 also allowed; else saturates at 255)
 *     signed 16-bit integer    bit 2 (stops at the first non-digit: "2.5E3" -> 2, "-3" -> 65533)
 *     decimal number           bit 3 (sign, digits, point, exponent)
 *     word                     bit 4 (any run of characters up to blank, ',' or ';'; kept in the buffer)
 *   A parameter that is not allowed drops the whole command. No parameter: the command runs only if
 *   bit 7 (bare) is set. Type 0x00 (CLM) always runs and ignores its parameters.
 */
#include <ctype.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

typedef struct {
    uint8_t type;        /* 2Dh: type byte of the command, minus the parameter kinds already used */
    uint8_t index;       /* 2Eh: command index (0x00-0x12 functions, 0x13-0x28 commands, 0x30 = end) */
    uint8_t flags;       /* 2Fh: bit7 ready, bit5 first parameter, bits0-2 kind, 0x70 = word */
    uint8_t int_val;     /* 30h for integers; for words: 30h = start position, 31h = length */
    uint8_t word_pos, word_len;
    double  number;      /* 30h-33h as pm_float for decimal numbers */
} token_t;

enum { KIND_OFF = 0, KIND_ON = 1, KIND_INT = 2, KIND_INT16 = 3, KIND_NUMBER = 4, KIND_NONE = 5,
       KIND_QUERY = 6, KIND_WORD = 0x70 };

typedef struct { char name[4]; uint8_t type, index; } cmd_entry_t;
extern const cmd_entry_t cmd_table[42];        /* ROM 0x59B1 */

/* emit callback: in the firmware the token is handed over through the shared context */
typedef void (*emit_fn)(const token_t *t);

static bool is_sep(char c) { return c == 0 || c == ' ' || c == ',' || c == ';'; }

/* name matching: a blank in the table entry matches anything */
static int find_command(const char *word, int len)
{
    for (int i = 0; i < 42; i++) {
        const char *nm = cmd_table[i].name;
        int need = (int)strcspn(nm, " ");               /* significant letters */
        bool ok = len >= need;
        for (int k = 0; ok && k < 3; k++)
            if (nm[k] != ' ' && (k >= len || toupper((unsigned char)word[k]) != nm[k])) ok = false;
        if (ok) return i;
    }
    return -1;
}

/* one parameter; returns false if the command does not accept what is there */
static bool parse_param(const char *line, const char **pp, const cmd_entry_t *c, token_t *t, bool second)
{
    const char *p = *pp;
    uint8_t typ = c->type;
    t->flags = (uint8_t)(second ? 0x80 : 0xA0);
    if (*p == '?') {
        if (typ & 0x20)      { t->flags |= KIND_QUERY; *pp = p + 1; return true; }
        if (typ & 0x10)      { t->flags = (uint8_t)(t->flags | 0x70); t->word_pos = (uint8_t)(p - line); t->word_len = 1; *pp = p + 1; return true; }
        return false;
    }
    if ((typ & 0x01) && (!strncasecmp(p, "ON", 2) || !strncasecmp(p, "OFF", 3))) {
        bool on = !strncasecmp(p, "ON", 2) && !isalpha((unsigned char)p[2]);
        t->flags |= on ? KIND_ON : KIND_OFF;
        *pp = p + (on ? 2 : 3);
        return true;
    }
    if ((typ & 0x02) && isdigit((unsigned char)*p)) {
        const char *q = p; unsigned v = 0;
        while (isdigit((unsigned char)*q)) { v = v * 10 + (unsigned)(*q - '0'); if (v > 9999) v = 9999; q++; }
        if (!(typ & 0x08) || (is_sep(*q) && v <= 255)) {
            t->flags |= KIND_INT; t->int_val = (uint8_t)(v > 255 ? 255 : v); *pp = q; return true;
        }
    }
    if ((typ & 0x04) && (isdigit((unsigned char)*p) || ((*p == '+' || *p == '-') && isdigit((unsigned char)p[1])))) {
        const char *q = p + 1; long v;
        while (isdigit((unsigned char)*q)) q++;
        v = strtol(p, NULL, 10);
        t->flags |= KIND_INT16; t->int_val = (uint8_t)v; t->word_len = (uint8_t)((uint16_t)v >> 8);  /* 30h/31h */
        *pp = q; return true;
    }
    if ((typ & 0x08) && (*p == '+' || *p == '-' || *p == '.' || isdigit((unsigned char)*p))) {
        char *end;
        t->number = strtod(p, &end);
        t->flags |= KIND_NUMBER; *pp = end; return true;
    }
    if (typ & 0x10) {
        const char *q = p;
        while (!is_sep(*q)) q++;
        t->flags = (uint8_t)(t->flags | 0x70);
        t->word_pos = (uint8_t)(p - line); t->word_len = (uint8_t)(q - p);
        *pp = q; return true;
    }
    return false;
}

/* parse one line (the original does this incrementally, one character per main-loop pass) */
void parse_line(const char *line, emit_fn emit)
{
    const char *p = line;
    for (;;) {
        while (*p == ' ') p++;
        if (!*p) break;
        const char *w = p;
        while (isalpha((unsigned char)*p)) p++;
        int ci = find_command(w, (int)(p - w));
        const cmd_entry_t *c = ci >= 0 ? &cmd_table[ci] : NULL;
        if (c) {
            token_t t = { c->type, c->index, 0xA0, 0, 0, 0, 0.0 };
            while (*p == ' ') p++;
            if (c->type == 0x00) {                    /* CLM: always, parameters ignored */
                t.flags = 0xA0 | KIND_NONE; emit(&t);
            } else if (!*p || *p == ';') {
                if (c->type & 0x80) { t.flags = 0xA0 | KIND_NONE; emit(&t); }
            } else if (parse_param(line, &p, c, &t, false)) {
                emit(&t);
                while (*p == ' ') p++;
                if (*p == ',' && (c->type & 0x40)) {
                    p++;
                    if (parse_param(line, &p, c, &t, true)) emit(&t);
                }
            }
        }
        /* skip to the next command: ';' always, ',' too if no second parameter is possible */
        bool comma_sep = c && !(c->type & 0x40);
        while (*p && *p != ';' && !(comma_sep && *p == ',')) p++;
        if (*p) p++;
    }
    token_t end = { 0, 0x30, 0xA5, 0, 0, 0, 0.0 };    /* end of message */
    emit(&end);
}
