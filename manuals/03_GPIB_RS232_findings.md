# PM2525 – GPIB (IEEE-488 / IEC-625) and RS-232C (V24) information

Extracted from OCR of the 4 unique scans (see `OCR/`). Page numbers = PDF page in the OCR'd file.
OM = `PM2525_user_manual_OCR.pdf` (operator manual, EN/DE/FR, 153 p.)
SM = `ilide.info-…service-manual…_OCR.pdf` (service manual PM2525/3 series, 1993, 112 p.)

Also searched (2026-11-22): 6 extra archive.org scans (`archive_manualsplus_*.pdf`, they already have a text layer,
plain text in `OCR/`). They add the interface **hardware**: board ICs, schematics and the RS-232 pinout (see below).

## Key finding: the interface programming manual is NOT among the scans
All three user manuals state that the interface versions use a separate manual:
"The following operation manuals should be used: PM2525/01 · PM2525/21 · **PM2525/51/61** · PM2525/71"
(OM p.13, ID6719 p.4, ID6720 p.3). The command set, address setting, baud rate, etc. are in
that **PM2525/51/61 interface operation manual**, which none of the downloaded files contain.

## Model variants / options
| Version | Interface | Option kit (SM p.2, p.89) |
|---|---|---|
| PM2525/01 | none (standard) | – |
| PM2525/21 | battery version | – |
| PM2525/51 | IEC-625 / IEEE-488 (GPIB) | standard + **PM9191** |
| PM2525/61 | RS-232C / V24 | standard + **PM9190** |
| PM2525/71 | analog output | standard + PM9193 |

- Interfaces mount in the **top cover** and connect to the mother board via a **galvanic separation** board/connector (SM p.19, p.48–49).
- "To be extended as system multimeter (IEEE-488, RS232C). Fully programmable (also function). Min/Max function." (SM p.19)
- Main CPU: Intel 8031AH (has its own full-duplex serial port, P3.0 RXD / P3.1 TXD) (SM p.41–43).
- RS232C/V24 interface board (SM parts list p.108–109): **SCC2692AC1N28 DUART**, **PCF84C41AP** microcontroller, crystal(s), transistors/diodes V0312…V0334, C1001…C1016.

## Front-panel / display behaviour (OM p.30, DE p.76, FR p.128)
IEEE-488/IEC-625 annunciators (not on /01):
- **REM** – remote; keyboard locked
- **SRQ** – service request
- **LSTN** – listener (ready to accept data)
- **TLK** – talker (ready to send data)
- **TLK ONLY** – talk-only mode, no controller needed
- **S TRG** – single-trigger mode; settable via the IEEE-488 interface (or the PM9267 data-hold probe)

Other mentions:
- CHECK function: "In case of PM2525/51/61 first the IEEE-488/IEC-625 parameters can be modified (4 steps)" before the software version is shown (OM p.38, DE p.84). This is the front-panel menu for interface settings (presumably address / talk-only / etc.; details are in the missing manual).
- Single trigger for data hold "is only possible via the IEEE-488 interface of the PM2525/51 or RS232C/V24 interface of the PM2525/61" (OM p.50, DE p.98).

## Remote commands documented in the service manual (calibration, SM p.71–74)
Calibration by computer control is done with an IEEE-488 controller (e.g. P3100, IBM-compatible), or with a
**PM9181 IEC-625 ↔ I²C interface** plugged onto the meter (needs a "help set" to fit the interface plug and the
4-wire ohm cable together, SM p.5-31). Fig. 5.3 shows control via "IEC-625 or RS232C/V24 interface" too.

First enable calibration on the front panel: press **CAL + RESET** together, release RESET first → display shows `CAL`.

| Command | Meaning |
|---|---|
| `CAL ON,0` | select cold calibration (+20…+26 °C) |
| `CAL ON,1` | select hot calibration (+33…+40 °C) |
| `CAL OFF` | 1st: leave cal mode → cal-enable; 2nd: leave cal-enable → normal measuring |
| `CAL?` | query actual cal mode (e.g. `CAL ON,0` / `CAL OFF`) |
| `TRG B,X` | start calibration of the selected range (OCR shows `TRG_B,X`/`ERG _B,X`; the underscore is probably a space) |

- Range/function are selected "by sending the corresponding commands" (not listed in the SM).
- Display shows value + `r` = calibration ready; `FAIL` = repeat; `nA` = range not calibratable.
- The meter shows **REM** during the computer-control calibration flow (flow-chart SM p.74).

## Interface hardware (from archive.org scans, added 2026-11-22)
Source: `archive_manualsplus_12344.pdf` (older service manual covering /01/21/51/61/71):
parts list p.100 and p.109, schematics p.137 (IEEE) and p.139 (RS232). `archive_manualsplus_14172.pdf`
p.146–152 has the same boards (same MC2682 DUART), so the design is unchanged between revisions.

### PM2525/51 IEEE-488 / IEC-625 board (SM12344 p.137, parts p.100)
- No dedicated GPIB controller chip. A microcontroller (D601, reads "MAB 8441"-type, **6 MHz** crystal G601)
  drives the bus in software through **SN75160A** (D603, data DIO1–8) and **SN75161A** (D602, control) transceivers.
- Talks to the meter over **I²C** (SDA/SCLK via connector X602), across the galvanic separation board
  (CNX36 optocouplers in the parts list).
- X601 = IEEE-488 connector with the standard pin numbering: DIO1–4 = 1–4, EOI 5, DAV 6, NRFD 7, NDAC 8,
  IFC 9, SRQ 10, ATN 11, shield 12, DIO5–8 = 13–16, REN 17, GND 18–24.

### PM2525/61 RS-232C / V24 board (SM12344 p.139, parts p.109)
- Microcontroller D1001 + **MC2682P DUART** (D1002, two channels A and B), crystal **3.6864 MHz**
  (a standard baud-rate crystal).
- Line drivers **MC1488** (D1003), receivers **MC1489A** (D1004); RX/CTS inputs pulled up with 10 kΩ (R1001 network).
- **S1001 = 14-position switch (a…n)**, read by the CPU through diodes V1001–V1014. These are the RS-232
  configuration switches (baud/format etc.). The meaning of each switch is NOT given in the service manuals.
- Connector **X1002 (DB-25)** pinout:

| Pin | Signal | Direction (meter) |
|---|---|---|
| 1 | GND | – |
| 2 | TxD A | out (MC1488) |
| 3 | RxD A | in (MC1489) |
| 5 | CTS A | in |
| 7 | GND (signal) | – |
| 20 | DTR A | out (DUART OP0) |
| 14 | TxD B | out |
| 16 | RxD B | in |
| 13 | CTS B | in |
| 19 | DTR B | out (DUART OP1) |
| shell | SHIELD (via J1003) | – |

Port A uses the normal DTE pins (2/3/5/7/20), so a PC connects with a **null-modem** cable with hardware
handshake: meter DTR→PC CTS/DSR, PC RTS/DTR→meter CTS. Port B is on the secondary-channel pins.

## Still not found in any scan
Full command syntax (function/range/speed/trigger), SRQ/status bytes, output data format, GPIB address
setting, the RS-232 switch S1001 settings (baud/parity/handshake), and which channel (A/B) does what.
These are only in the **PM2525/51/61 operation manual** (Philips 4822 872 …), which is not online as far as
searched: KO4BB, BAMA, Opweb/lost-manuals, archive.org, ManualsLib, Scribd listings.
Searched for: "PM2525/51/61 operating manual", "PM9190", "PM9191". Not yet tried: eBay/paper copies, or
the EEVblog / mikrocontroller.net / circuitsonline forums (asking whether someone has a copy).
