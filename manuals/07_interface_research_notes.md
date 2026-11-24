# Philips / Fluke PM2525 – GPIB & RS-232 option research

_Compiled 2026-11-18. Main source: PM2525 service manual 4822 872 3xxxx (rev. 930701), archive.org scan (OCR – part numbers double-checked where possible)._

## 1. Option overview

| Suffix (type plate) | Option board | Contents |
|---|---|---|
| PM2525/x0 | – | standard |
| PM2525/x2 | – | battery version (plastic back panel) — *not* an interface |
| PM2525/x5 | **PM9191** | IEEE-488 / IEC-625 interface |
| PM2525/x6 | **PM9190** | RS-232C / V24 interface (sold as "multidrop") |
| PM2525/x7 | **PM9193** | analog output |
| (external) | **PM9181** | IEC-625 ⇄ I²C adapter, plugs into the front PROBE socket (used for calibration) |

Dealer option codes seen: 013 std, 213 battery, 513 GPIB, 613 RS-232 multidrop, 713 analog out.
Option boards mount in the **top cover** ("In the topcover the interfaces can be mounted") and connect to the motherboard via a **10-pin connector**.

## 2. Meter architecture (what matters for an interface)

- Main CPU: **8031AH** (later 80C31), external **EPROM D1710** (socketed, 74HC373 address latch), **2 KB SRAM HM6116 D1711**.
- Everything else is on **I²C**: ADC interface OQ0071 (D1714), LCD driver PCF8576, keyboard via PCF8574, and the interface option board.
- The 8031 is the **I²C master**; the option board's MCU is an **I²C slave** (stated explicitly in the sister PM2534/35 manual).
- **ASCII command parsing is done by the main 8031 firmware**, not the option board. Evidence: the PM2534/35 firmware release notes change how command strings are interpreted (e.g. 30-char buffer fix, new `EMO` command) with no interface-board change. → The option board is just a **byte pipe + bus-state handler**.
- The OQ0071 ADC chip uses a non-standard I²C addressing scheme (upper nibble = group address, lower nibble = command). Generic I²C sniffers get confused by it — matches the EEVblog report of a Bus Pirate seeing only `0x00 ACK 0x00 ACK`.

## 3. PM9191 IEEE-488 board (parts list)

| Part | Function |
|---|---|
| **PCF84C41AP/089** | Philips 8048-family MCU with hardware I²C, mask ROM (code /089). Does the full GPIB handshake in firmware |
| DS75160AN | GPIB data transceiver (DIO1-8) |
| DS75161AN | GPIB control/handshake transceiver (single-controller version) |
| HEF40245BP | bus buffer |
| 74LS02, 74LS05 | glue logic (talk-enable, open-collector) |
| 6.0 MHz crystal | MCU clock |

No dedicated GPIB controller chip (no TMS9914 / µPD7210) – bit-banged by the MCU.
Behaviour per PM2534 manual §3.5: on MLA it handshakes in data bytes; on MTA (or in talk-only) it switches the 75160/161 to transmit, sends bytes and asserts **EOI on the last byte**; remains talker until addressed to listen again or IFC.

The PM2534 notes say the MCU was changed from **MAF8441 → PCF84C41** "to fulfil the demands of IEEE488.2" — so early units are 488.1 only (explains the NI-forum trouble with modern VISA auto-detect).

## 4. PM9190 RS-232 board (parts list)

| Part | Function |
|---|---|
| **PCF84C41AP/089** | same MCU type *and same mask code* as the GPIB board (likely one firmware, function picked by hardware strap) |
| **SCC2692AC1N28** | Philips DUART (2 channels – the 2nd channel is probably the "multidrop" in/out) |
| 3.6864 MHz crystal | DUART baud clock |
| DS14C88 / DS14C89A | RS-232 line driver / receiver |
| 25-pin D-sub | RS-232 port; 10-pin header to motherboard |

From PM2534/35 notes (same family): for RS-232 control set the meter **addressable (tONLY 0)** and send **`<ESC>2`** to enter remote mode; for a printer, talk-only (tONLY 1). Baud rate etc. are not in the service manual – need the PM9190 manual or the operating manual.

## 5. PROBE socket (front) – I²C is already exposed

- 8-pin DIN, **262° "U-style"** (DIN IEC 60574-18) – normal 270° DIN plugs don't fit.
- Carries 4-wire Ω / Pt100 sense, data-hold probe, **and the I²C bus**.
- EEVblog (MrAureliusR, 2013): **pin 5 = SCL, pin 6 = SDA, ~70 kHz**. Unverified by others – check against the "help set" drawing on service manual p.5-31.
- Philips used this with the external **PM9181 IEC-625⇄I²C adapter** for computer-controlled calibration. The manual shows full remote control this way (`CAL ON,0`, `TRG B,X`, range/function commands).
- **This is the easiest route:** a microcontroller on the PROBE socket can act as the PM9181/option slave without opening the meter or building a top-cover board.

## 6. Known commands (from the cal section; full list is in the operating manual)

```
CAL ON,0    cold calibration      CAL ON,1   hot calibration
CAL OFF     leave cal mode (send twice to leave cal-enable)
CAL ?       query cal mode
TRG B,X     trigger
OUT N,6     (PM2534 example) output only 6 numeric results
EMO         enable measurement output (PM2534 S04+)
```
Philips 25xx syntax is `MNEMONIC␠ARG,ARG` (the OCR shows the space as `_`), terminated by EOI or LF.

## 7. Existing open-source material

- **inaxeon / PTV_Preservation – PM8547 recreation** (GPIB/RS-232 option for the Philips PM5644 TV pattern generator). Same Philips-era design idea: PCF84C00 (ROM-less 84C41) + EPROM, I²C slave to the host. Includes schematic, Gerbers, BOM, manual, and a **ROM dump of the bridge firmware**:
  https://github.com/inaxeon/PTV_Preservation/tree/main/PM5644/PM8547_20
  The author calls it "PM8547 a.k.a. PM9191". **That is unconfirmed**: the PM9191 uses a mask-ROM PCF84C41 /089, not an 84C00 + EPROM. Still the best reference for the I²C framing Philips used.
- MagicSmokeBlog / Philips-PM2535-Kermit – LCD replacement; contains I²C decoding of the display bus:
  https://github.com/MagicSmokeBlog/Philips-PM2535-Kermit
- GPIB side: AR488 (Arduino), UsbGpib, galvant GPIB-USB – reusable for the GPIB physical layer.

## 8. Unknowns (what must be reverse engineered)

1. I²C slave address of the option board (and whether GPIB/RS-232/analog boards use different ones).
2. Framing: how the 8031 polls for received bytes, end-of-message / EOI flag, SRQ request, serial poll status byte, GPIB address and talk-only setting transfer, REN/GTL/remote-local.
3. 10-pin option connector pinout (expected: VCC, GND, SDA, SCL, maybe /INT, /RESET, supply rails for isolation).
4. Whether the option board is galvanically isolated (no opto-couplers in the parts list → probably not; the meter's "COM" floats, so be careful).

## 9. Suggested plan

1. **Read the EPROM D1710** from one meter (27C256/27C512-class, socketed) and disassemble it (Ghidra 8051). Find the I²C master routines → find all I²C addresses → the one that is not ADC/LCD/keyboard is the option board. The master side defines the whole protocol, so the PCF84C41 mask ROM does not need to be dumped.
2. **Logic-analyse the PROBE pins 5/6** while sending commands from the front panel/cal mode. Use a custom decoder (sigrok/PulseView) because of the OQ0071's odd addressing.
3. Cross-check with the **PM8547 firmware dump** (8048 code, disassemble with the d48 or Ghidra MCS-48 module).
4. Build the replacement: RP2040 / STM32 as the I²C slave + USB-CDC (easiest), then RS-232 (MAX3232) or GPIB (AR488 core + SN75160/161). Start on the PROBE socket (no board needed), then make a top-cover board for the 10-pin connector.
5. Get the **operating manual** (ManualsLib, BAMA `PM2525_user_manual.pdf`, Opweb) for the full command list, IEEE address setup and RS-232 settings.

## Sources

- Service manual (OCR text): https://archive.org/stream/philips_PHILIPS_PM_2525_Service/PHILIPS_PM_2525_Service_djvu.txt
- PM2534/35 service manual: https://archive.org/stream/philips_pm2534_PM2535/pm2534_PM2535_djvu.txt
- Probe connector thread: https://www.eevblog.com/forum/testgear/pm2525-multimeter-probe/
- PM9190/PM8547 thread: https://www.eevblog.com/forum/testgear/anyone-got-a-philips-multimeter-pm2525-pm2535-pm2534-etc/
- LCD/I²C thread: https://www.eevblog.com/forum/repair/philips-pm2525-alternative-lcd-display/
- Option codes: https://testequipment.center/Products/Philips-PM2525
- Operating manual: https://www.manualslib.com/products/Philips-Pm2525-3753033.html · https://bama.edebris.com/manuals/philips/pm2525/ · https://www.opweb.de/en/manufacturer/philips/pm2525
- NI threads (command set / driver): https://forums.ni.com/t5/Instrument-Control-GPIB-Serial/GPIB-command-set-for-Philips-Fluke-PM6665-PM2525-and-PM2519/td-p/415407
