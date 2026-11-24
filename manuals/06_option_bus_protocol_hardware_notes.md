# PM2525 option-bus protocol (decoded from firmware "PM25250 S08")

Source: EPROM dump `AM27256_PM2525.BIN` (32 KB, 8031 code) from KO4BB
(http://eww.ko4bb.com/getsimple/index.php?id=manuals&dir=Philips/PM2525_Digital_Multimeter).
Disassembly: `tools/d51.py`, listings in `tools/`. Firmware ID string at 0x5989: `PM25250 S08`.

Status: the **bus, address and framing are read straight from the code (high confidence)**.
The **meaning** of each status code (GPIB event names) is inferred and must be confirmed by
sniffing or testing.

---

## 1. Two I²C buses on the 8031 (both bit-banged, both support clock stretching)

| Bus | SCL | SDA | 8031 DIP-40 pins | Used for |
|---|---|---|---|---|
| A (internal) | P3.5 | P1.7 | SCL = pin 15, SDA = pin 8 | LCD driver PCF8576 (0x70), keyboard PCF8574 (0x48), ADC interface OQ0071 (0x80–0x8D), and the 74HC4094 shift registers (P1.3 = strobe, pin 4) |
| **B (option)** | **P3.2 / INT0** | **P1.1** | **SCL = pin 12, SDA = pin 2** | **Interface option (PM9190/9191/9193) and very likely the PROBE socket / PM9181** |

Bus B has extra NOPs in every clock phase (it's slower, about the 70 kHz an EEVblog user measured on the PROBE socket) and waits for SCL to go high. That is what you'd design for a bus running through the optocouplers on the galvanic-separation board.

Code: START+write-address 0x6356, START+read-address 0x6367, send byte 0x6376 (C=1 → NACK),
send-ACK 0x63C0, read byte 0x63D9, NACK+STOP 0x633B, STOP 0x63A7, write-1-byte 0x6342.

## 2. Slave address

`7F1D: A = ((R4 >> 4) & 0x06) | 0x58`

- 8-bit write address **0x58** / read **0x59** → **7-bit 0x2C** (default).
- Two bits of the option-state byte can move it to 0x5A/0x5C/0x5E (7-bit 0x2D–0x2F).
- Start by answering on **0x2C**. Answering on all of 0x2C–0x2F costs nothing.

### Confirmed by logic-analyser capture on the 10-pin header (2026-11-19)

The bus runs at about 67 kHz (134 µs per address byte). With nothing connected, the capture shows:

| 7-bit addr | 8-bit | Rate | Firmware | What it is |
|---|---|---|---|---|
| 0x27 (read) | 0x4F | every ~5 ms | 0x31CF / 0x3203 / 0x1534 via 0x6333 | PCF8574-type port expander. Bit 7 is read as a debounced pushbutton that toggles "hold". Writes `FD`/`FF` back (bit 1 = hold indicator; bit 0 tracks flag 26.6). This is almost certainly the **data-hold probe (PM9267)** on the PROBE socket, which proves the PROBE socket shares bus B. NACK → feature off. |
| 0x2C (write) | 0x58 | every ~55 ms | 0x7D05 via 0x7F24 | **Interface option slot 1** (state block XRAM 0x0053). NACK = no board fitted. |
| 0x2F (write) | 0x5E | right after 0x2C | same code, state block 0x0059 | **Option slot 2**, probably the analog-output PM9193 or a second interface |

The lone STOPs about every 0.95 ms come from 0x5331: `ANL P3,#DBh` pulls both SCL lines low, then STOP is sent on both buses (a periodic bus reset). A slave must tolerate a STOP that has no START before it, which is legal I²C.

### ✅ Confirmed on real hardware (2026-11-19, Pro Micro as slave 0x2C, meter "PM25253 S25")

| Step | Bus traffic | Result |
|---|---|---|
| Slave ACKs 0x2C | meter writes `F8`, `F4`, `FE`, `FA` (one byte per transfer) | interface accepted |
| **Idle reply must be `80 00`**, not `FF` | `FF` is counted down by the meter (0x7DCC); at 0 it re-runs the init above (every ~13 ms) | with `80 00`: init once, then quiet polling (~1600 reads/s) |
| `.id` → reply `E1` | meter writes `6B "PM25253 S25" EF` | framing + checksum confirmed |
| Command, e.g. `44 'V' 'D' 'C' 0A C3` (bit6 END + LF) | meter writes `FF` = message received (0x7DA5), then a status byte | accepted |
| `EMO` | `FF`, status `B1`/`91` | measurement output enabled |
| `TRG B` | `FF`, status `81` | trigger |
| `FE` (talk) | first: status `80`/`81` (busy); next: `73 "VDC  ? +999.999E+09" 81` | **reading received** (input open = overrange) |
| `80 00` after a data block | meter does not resend | data ACK works |

Readings come with header `60+N` (bit6 = END), same as the ID string.

### Status byte (meter writes one byte `80`–`BF`)

Mechanism (S08 code, 0x7F6B): `byte = 0x80 | (RAM[0x2E] & 0x3F)`; the meter sets bit 7 of 0x2E as a "sent" flag.
In S08, 0x2E is the meter's **mode flag byte**, changed by command handlers (e.g. `ORL 2Eh,#21h` / `ANL 2Eh,#DEh`).
So the "status" is mostly the meter telling the interface its current mode, plus event bits.

Observed on the real meter (firmware S25), reproducible:

| Event | Bytes sent | Bits |
|---|---|---|
| unknown command (`XYZZY`) | `90` → `B4` (~400 ms later) → `91` | 4; then 5+4+**2**; then 4+0 |
| `EMO`, also `FNC 99` | `A1` → `80`/`81` | 5+0, then (0) |
| `TRG B` / measurement pending | `81` (on next FE) | 0 |
| reading collected | `80` | none |
| valid function / range commands (`VDC`, `RTW`, `RNG 3`) | none (only `FF` = received) | – |
| out-of-range parameter (`RNG 99`) | none, silently accepted | – |

Working interpretation (confidence):

| Bit | Meaning | Confidence |
|---|---|---|
| 7 | always 1 (marks a status byte, 80–BF range) | certain (code) |
| 6 | always 0 (masked by `& 0x3F`) | certain (code) |
| 5 | attention / mode change: set by `EMO`, by `FNC 99` and on errors | likely |
| 4 | error or message state: set during the error sequence, also seen as `90`/`91` after FE before EMO | unclear |
| 3 | never seen set | – |
| 2 | **command error** (only in `B4`, after an unknown command) | likely |
| 1 | never seen set | – |
| 0 | **measurement armed / not yet output**: set after a trigger, cleared once the reading is collected | likely |

The meter does **not** send status after every command. A host doesn't need these bits for readings:
`EMO` → `TRG B` → `FE` (repeat FE until a `6x` data block arrives).

### Interface → meter event codes (confirmed on the meter, 2026-11-19)

Sent as the reply to the meter's poll (one byte). This is how the original GPIB board signals bus events:

| Code | Observed effect | GPIB equivalent |
|---|---|---|
| `F5` | no visible change | REN asserted (remote enable, takes effect when addressed); inferred |
| `F8` | **REMOTE shown, front keys locked** | remote + local lockout (LLO) |
| `F6` | REMOTE off, keys work | REN false (back to local, clears lockout) |
| `F7` | REMOTE off, keys work | GTL (go to local); in the code it only applies under a condition |
| `F9` | status `90`→`91`→`81`, then a **fresh, valid reading** (flag `?` → blank) | GET (group execute trigger) |
| `FA` | status `90`, then the **meter does a full restart** (confirmed twice); interface state is kept | SDC / DCL (device clear = reset to power-on state) |
| `FE` | meter sends its reading if one is ready (else status, then sends on the next FE) | addressed to talk (MTA) |
| `E1` | meter sends its identity `6B "PM25253 S25" ck` | (identify) |
| `80 xx` | idle / nothing to report (2-byte status) | – |
| `FF` | **do not use as idle**: the meter counts it down and re-inits the interface | – |

The meter measures continuously; every FE pair returns the latest reading. Status bit 4 (`90`) appears whenever
the meter takes in a bus event (F9, FA, errors).

### Reading format

`"VDC  ? +999.999E+09"`: function (3 chars), 2 spaces, flag char, space, value in E-notation.
Flag char seen: `?` (normal so far, input open) and `O` (once, right after an error). Meaning still open.

### Queries and settings dump (confirmed on the meter, S25)

Every settable command has a query form `XXX ?`. The answer comes as a data block on the next FE:

| Query | Answer (default state) | Notes |
|---|---|---|
| `FNC ?` | `FNC VDC` | function |
| `RNG ?` | `RNG     AUTO` | range |
| `MSP ?` | `MSP 1` | measuring speed |
| `RSL ?` | `RSL 6` | resolution |
| `TRG ?` | `TRG I` | trigger mode (I = internal, B = bus) |
| `OUT ?` | `OUT S` | output mode |
| `DBM ?` | `DBM OFF,+600.0000E+00` | dBm on/off, reference resistance |
| `ZER ?` | `ZER OFF,+.0000000E+00` | relative/zero on/off, offset |
| `MIN ?` / `MAX ?` | `MIN ,VDC    -000.019E-03` | min/max memory with function |
| `CAL ?` | `CAL  OFF` | calibration mode (**never set**) |
| `CR ?` / `SIX ?` | `CR  OFF` / `SIX OFF` | |
| `IEE ?` | `IEE 022` | interface config (GPIB address 22?) |
| `JCV ?` | `JCV 001,000,001,000,000,021` | **service/cal data? never set** |
| `CDP ?` | `CDP  001,+1.200000E-02` | **service/cal data? never set** |
| `RMS ?` | `RMS 087` | **service/cal data? never set** |
| `CLM`, `X`, `EMO`, `TOL` | no query form, act immediately | CLM = clear min/max, X = execute |

**`DMP ?` = complete settings dump (learn string)**, sent as 11 blocks (`2x` header, no END, last block `6x` with END):
`FNC VDC;RNG     AUTO;DBM OFF,+600.0000E+00;ZER OFF,+.0000000E+00;MSP 1;RSL 6;TRG I;CAL  OFF;OUT S;CR  OFF;SIX OFF`
→ Multi-block answers must be reassembled until a block with END (bit 6) arrives. One block per FE.

### Allowed values (probed on the meter, S25: set, then query back)

| Command | Accepted | Rejected (status `B1`) | Notes |
|---|---|---|---|
| `FNC x` | `VPU VPL VPP VDC VAC VRM RFW RTW IDC IAC TPP TPN TNP TNN CAP FRQ TDC DIO CON` | anything else | the bare mnemonic (e.g. `VAC`) works too |
| `RNG x` | a **value**: the smallest range covering it is chosen (`0.2`→200 mV, `0.21`→2 V, `21`→200 V, `201`→2 kV, `2E2`, `200E-3`); `AUTO` or `A` | `M`, `UP`, `DN` | answer e.g. `RNG 200.E-03`, `RNG     AUTO` |
| `MSP n` | `1 2 3` (speed) | 0, 4, 5 | |
| `RSL n` | `4 5 6` (digits) | 3, 7 | |
| `TRG x` | `I` internal (free-run), `B` bus, `E` external | all other letters | |
| `OUT x` | `S` (reading with function prefix), `N` (number only) | `N,6` and other letters | `OUT N` → `" -000.020E-03"` |
| `CR x` | `ON` (appends `\r` to every output), `OFF` | `1`, `0` | |
| `SIX x` | `ON`, `OFF` | `1`, `0` | meaning still open |
| `DBM x[,r]` | `ON`/`OFF`, optional reference R (`DBM ON,50`) | | |
| `ZER x[,v]` | `ON`/`OFF`, optional offset (`ZER OFF,1.5`) | | |

Function mnemonics: VPU/VPL/VPP = peak +/−/pp, VDC, VAC, VRM = AC+DC rms, RFW = Ω 4-wire, RTW = Ω 2-wire,
IDC, IAC, TPP/TPN/TNP/TNN = time interval (start/stop edge ±), CAP, FRQ, TDC = temperature °C, DIO = diode, CON = continuity.

### Status byte: final map

| Bit | Meaning | Evidence |
|---|---|---|
| 7 | always 1 | code |
| 6 | always 0 | code |
| 5 | **execution error** (parameter out of range / unknown value) | `B1`/`A1` after every rejected value |
| 4 | **free-running (TRG I) active** | `90` in TRG I, cleared in TRG B/E |
| 2 | **command error** (unknown command) | `B4` (~400 ms later) after unknown mnemonics |
| 0 | measurement armed / result pending | `81` after triggers, cleared when collected |
| 3, 1 | never seen | |

### Design rules for the emulation (from these tests)

1. **Commands to the meter:** split host strings at `;` into complete messages of ≤ 29 bytes, each with END.
   A long string cut in the middle of a command is ignored (110-char learn string was not applied).
   Short chains like `MSP 2;RSL 5` in one message work.
2. **Answers from the meter:** reassemble blocks (`2x` = more follows) until a block with END (`6x`). One block per FE.
3. **Error reporting:** bit 5 (`B1`) and bit 2 (`B4`, arrives ~400 ms late) map to GPIB serial-poll status.

### Command set (S08 command table at 0x5995, 41 entries)

`VPU VPL VPP VDC VAC VRM RFW RTW IDC IAC TPP TPN TNP TNN CAP FRQ TDC DIO CON` (functions, index 00–12),
`FNC RNG DBM ZER MIN MAX CLM MSP RSL TRG X CAL OUT JCV DMP CDP RMS SIX CR EMO IEE TOL`.
Confirmed on S25: `VDC VAC RTW RNG FNC TRG EMO`, identity via `E1`. **Avoid `CAL`** (calibration).

**To finish the status map exactly:** read the meter's own EPROM (D1710, 27C256, socketed) with a
programmer (e.g. TL866). With the S25 image the 0x2E handlers can be decoded per command.

**Wiring lessons:** the 10-pin header carries **-18 V** on one pin. The TXS0108 does not work on this bus
(nothing passes, even with pull-ups). The 5 V Pro Micro connects directly (D2 = SDA, D3 = SCL, GND),
with 4.7 kΩ pull-ups to the meter's +5 V and its internal pull-ups off.

## 3. Detection and initialisation (poll routine 0x7CE0)

The meter **polls** the slave; there is no interrupt line. (INT0 is on the same pin as SCL-B, and its vector 0x0003 goes to a restart path, so **never hold SCL-B low for long**.)

1. The meter sends START + 0x58. **If the slave ACKs**, the interface is marked present (B.7).
2. It then writes this init sequence (each item is its own START/0x58/bytes/STOP):
   - `FD 40` (only in some states)
   - `80|cfg` (from RAM 0x2E: mode bits, probably talk-only and similar)
   - `F8`
   - `F3`, then `C0|addr` (GPIB address 0–30), if R4.7 is set
   - one of `F4` / `F5` / `F6` (state bits from R3)
   - `FE` (conditional), then `FA`

## 4. Meter → interface (I²C writes to 0x58)

| Bytes | Meaning (inferred) |
|---|---|
| `C0+a` (a = 0–30) | set GPIB address / talk-only bits |
| `80+cfg` | configuration byte |
| `F0` | query (meter then reads; reply `F0` = special case) |
| `F1 xx` | send status byte xx (probably the serial-poll / SRQ status byte) |
| `F3`–`F8`, `FA`, `FB`, `FE`, `FF` | single-byte control and handshake codes |
| `FD 40` | init / reset |
| **`20+N  d1..dN  CK`** | **measurement / reply data**, N ≤ 31 bytes from XRAM 0x0034; bit 6 of the header is carried through (probably "last chunk / EOI") |
| **`60+N  d1..dN  CK`** | identity string, sent from ROM: `6B "PM25250 S08" CK` |

After each data block the meter reads one status byte back; bit 0 = 1 means "resend".

## 5. Interface → meter (I²C reads from 0x59)

First byte read = header/status:

| First byte | Meaning |
|---|---|
| `0 F F n n n n n` (bit 7 = 0), n > 0 | **n command bytes follow, then a checksum**. The meter ACKs each one and NACKs the checksum. Stored at XRAM 0x0013 (32-byte buffer) and passed to the command parser (0x4D56). |
| same with n = 0 | flags only; bit 6 set → "end of message / execute" (sets flag 2F.2) |
| `100aaaaa` | the interface reports its address switches (a = 0–30) |
| `FF` | nothing to report, idle (**the default answer**) |
| `FE` | interface wants output: the meter was addressed to talk (MTA), so send the result |
| `E1` | identity request: the meter replies with the `60+N` ID block |
| `F5` `F6` `F7` `F8` | remote / local / lockout state changes (REN, GTL, LLO) |
| `F9` | sets flag 2F.0, likely GET (trigger) |
| `FA` | sets flag 2F.1, likely SDC/DCL (device clear) |
| `FB` / `FD` | ask the meter to resend its address / config |
| `C0`–`FF` in some read paths | a second byte follows (2-byte status) |

## 6. Checksum (both directions)

```c
uint8_t ck = 0;
for (i = 0; i < n; i++) { ck = ck + data[i]; ck = (ck >> 1) | (ck << 7); }  /* add, then rotate right */
```
Only the data bytes are summed, not the header. The receiver XORs its sum with CK; it must be 0.

## 7. Minimum slave to get readings over USB

1. I²C slave at 7-bit 0x2C, open-drain, ≤100 kHz, **clock stretching allowed**
   (the meter waits for SCL to go high, so you can stretch while you prepare data).
2. Read with nothing pending: return `FF`.
3. Host command "VDC": return `20+3 'V' 'D' 'C' CK`, then on the next poll `40` (n = 0, bit 6 = execute).
   *(Exact header bit for "end" still to be confirmed: try `60+n` / `40` combinations.)*
4. To get a reading: return `FE` (talk request); the meter writes `20+N <ascii result> CK`. ACK it,
   then return status bit 0 = 0.
5. Log every write from the meter while you test. The init sequence in §3 gives you a free
   self-test: if you see `F8`, `F3`, `C0+a`... your ACK on 0x58 worked.

## 8. Finding the pins on your 10-pin header (do this with the meter UNPLUGGED)

Beep out with a continuity tester from the 8031 (40-pin DIP) to the header and to the PROBE DIN:

| 8031 pin | Signal | Expect on |
|---|---|---|
| 12 | P3.2 = **SCL-B** | 10-pin header, and probably PROBE pin 5 |
| 2 | P1.1 = **SDA-B** | 10-pin header, and probably PROBE pin 6 |
| 20 | GND (digital) | header |
| 40 | +5 V | header (check under power, measured against pin 20) |
| 11, 13, 14 | P3.1, P3.3, P3.4 | the firmware reads these at start-up; one may be an "option fitted" or battery sense line |
| 15 / 8 | SCL-A / SDA-A | should *not* reach the header |

The remaining header pins are probably transformer or battery supply lines (the same socket is used by the battery board on /2 units). **Measure them under power before connecting anything.**

## 9. Safety: isolation is mandatory

The header is on the meter side of Philips' galvanic separation. Meter digital ground is tied to the input COM, which floats with whatever you measure. Philips put the galvanic separation board A300 between this header and the interface: 9 optocouplers CNX36U (H0301–H0310), 3× LM393N, ICL7660, LM7805, BSX20/BC547B drivers and its own rectifier (4× BYV27-150). (Source: parts list in the PM2525 service manual; the circuit diagrams are missing from the KO4BB/archive.org scan. T301 is the meter's mains transformer, not a separate one.) You need the same:

- I²C isolator: **ISO1540 / ISO1541 / ADuM1250**. Side 1 runs from the meter's 5 V; side 2 from your MCU's 3.3 V. These also do the 5 V → 3.3 V level shift, which the RP2040 needs.
- Power the MCU side from USB, never from the meter. Or isolate the USB link itself (ADuM3160 / ADuM4160).
- An isolated DC-DC converter is only needed if you want to power the MCU from the meter.

## Second meter (also "PM25253 S25"), compared 2026-11-22

Same ID string, same address (`IEE 022`), the same 21 commands answer, and the `DMP ?` layout is identical
(only the user settings differ: `MSP 2;RSL 5`).
Differences:

| Item | Meter 1 | Meter 2 |
|---|---|---|
| `JCV ?` | `001,000,001,000,000,021` | `128,077,096,015,000,239` |
| `CDP ?` | `CDP  001,+1.200000E-02` | `CDP E001,+1.687500E-05` (`E` in place of the space) |
| `RMS ?` | `087` | `065` |
| reading flag char | blank (`VDC    +000.141E-03`) | `N` at every RSL/MSP (`VDC  N +000.283E-03`), also in `MIN ?`/`MAX ?` |

JCV/CDP/RMS differ per unit → per-unit calibration/service data (still: never set them).
`N` = **not calibrated**: meter 2's display shows "NC". The flag was already in its stored `MIN ?` record,
which was read before any action command was sent, so the calibration was lost before this session.
(`?` = not settled, `O` seen before.) Host parsers must accept any flag char.
Note: `CLM ?`, `X ?`, `EMO ?`, `TOL ?` are not queries: they execute (CLM clears min/max) and return a reading.

## S25 firmware (dump `rom/PM2525_S25.bin`, 2026-11-24)

27C256, MD5 a2f9121a0083f12b186cc1258656c072, ID string `PM25253 S25` at 0x59A6. Only ~5 % of bytes are identical to S08
at the same address (code shifted), but the structure is the same. S08 copy: `rom/PM2525_S08.bin`.

**Command table** at 0x59B1: 42 entries (S08: 41) of `name[3], flags, index`.
Flags bit 5 (0x20) = **query (`?`) allowed**. This explains why `CLM/X/EMO/TOL ?` execute instead of answering.

| Change vs S08 | S08 | S25 |
|---|---|---|
| `SIX` flags | 01 (no query) | 21: `SIX ?` added |
| `CR` flags | 01 | 21: `CR ?` added |
| `IEE` flags | 02 | 22: `IEE ?` added |
| **`MTS`** | – | **new**, flags 20, index 27h: query only, the execution handler is empty |
| `EMO`/`TOL` index | 27h | 28h (`TOL` is still an alias for the `EMO` handler) |

- Query jump table at 0x5189 (index 13h…27h); execution jump table at 0x465D (index 00h…30h).
- **`MTS ?`** returns the XRAM byte 0x01CB as 3 digits. It's written at 0x25FF by a timer-based counting routine
  (count/2). It's probably a measured timing value, perhaps mains-period related. Not yet tested on a meter.
- **`IEE n`** (n = 0…30) sets the GPIB address and stores it in non-volatile RAM (handler 0x459E → 0x3FBA). Bit 7 is kept.
  From the bus it's only accepted if XRAM 0x58 bit 7 is set, otherwise it's an execution error.
  Read via 0x5ACF: an invalid value or 31 → default **22** is written back.

**Non-volatile settings = the battery-backed 6116 (0x0000–0x07FF).** Small settings are stored three times
(0x03CA+n, 0x0599+n, 0x0768+n, with majority vote; 0x5B1B read, 0x5B67 write). Item 1 = IEE address, item 4 = `'a'`/`'N'`
(set by `CAL` sub-commands, 0x450E…0x4520).
`RMS` lives at 0x07FD…0x07FF as value / value+55h / value+AAh; if invalid it defaults to **0x41 = 65**.
Meter 2 answered `RMS 065`, which is that default, so it confirms the RAM loss from the flat battery.

**Calibration-invalid flag = bit 23.7.** It's set by the calibration checks at 0x0471…0x07FF (also bit 1 of XRAM 0x0770).
`CDP ?` prints the prefix `E` when 23.7 is set (meter 2: `CDP E001`), `N` when item 4 = `'a'`, otherwise a blank.
The `N` in readings and the display "NC" most likely come from the same flag (not traced in full).

Meter 1 (2026-11-24): `MTS ?` → `MTS 003` (stable over 2 queries); `RMS 087`, `CDP  001,+1.200000E-02`, settings unchanged.
The first `++read` after a pause returned the flag char `R` (`VDC  R  +000.16E-03`); the following readings had a blank flag.
Known flag chars so far: blank, `?`, `O`, `N` (not calibrated), `R` (meaning unknown, transient).
