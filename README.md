# TruckSuite OS (Pi Crow Terminal)

Flashable Raspberry Pi OS Lite (Bookworm, 64-bit) image with:
- OBD-II + J1939 diagnostics
- Read/clear codes (Mode 03/04; DM1/DM2/DM11/DM3)
- VIN, live gauges, CSV logs
- Auto-detect OBD vs J1939 (500k/250k)
- Autologin console + auto-launch menu
- MCP2515 overlay for Crow Terminal (spi0-0, 16MHz, INT=GPIO25)

## Download image (after first CI run)
1. Open **GitHub → Actions** → wait for **Build image** to finish.
2. Go to **Releases** → download `trucksuite-*.img.xz`.
3. Flash with Raspberry Pi Imager or balenaEtcher.
4. Boot → it drops you straight into the **TruckSuite** menu.

Wiring (Crow CAN ↔ truck):
- Crow `CH`→ J1939 pin **C** (CAN-H), `CL`→ **D** (CAN-L), `GD`→ **A** (GND). **Do NOT** use +B.
- OBD-II: pin **6** (CAN-H), **14** (CAN-L), **4/5** (GND). Ignore pin 16 (+12V).

Black 9-pin = 250 kbit/s; Green 9-pin = 500 kbit/s; OBD-II = 500 kbit/s.
