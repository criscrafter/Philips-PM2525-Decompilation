/* func_to_cmd_index - C replacement for the assembly routine at 0x4814 (first C routine in the
 * firmware; also the template for porting more of them).
 *
 * Returns the cmd_table index of the current function's mnemonic (VPU..CON), used by FNC?, RSL
 * and every reading's header. Called through the assembly glue `func_to_cmd_index` in
 * pm2525.asm, which keeps the original interface (result in A, registers preserved).
 * Verified: tools/check_clean.py "cmd_index" (all functions x mode bits) on the built image. */
#include "pm2525_fw.h"

unsigned char c_func_to_cmd_index(void)
{
    unsigned char f = meter_state & 0x0F;
    if (f == 0)
        return (unsigned char)((meter_mode >> 6) - 1);      /* Vpeak: VPU, VPL, VPP */
    if (f < 8)
        return f + 2;                                        /* VDC .. IAC */
    if (f == 8)
        return ((meter_mode >> 4) & 3) + 10;                 /* TPP TPN TNP TNN */
    return f + 5;                                            /* CAP FRQ TDC DIO CON */
}
