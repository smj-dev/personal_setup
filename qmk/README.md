# QMK Setup & Flash Guide (GMMK Pro ISO Nordic)

This directory contains a ready-made keymap JSON to be imported into **QMK Configurator**, build, and then flash with **QMK Toolbox**.

## 1) Open QMK Configurator
- URL: https://config.qmk.fm

## 2) Import the JSON
- Click **Import Keymap** and select the JSON from this repo:
  - `gmmk_pro_swedish_iso_keymap.json`
- Verify the layout shows **GMMK/pro/rev1/iso**.

## 3) Compile the firmware
- In Configurator, click **Compile**.
- When compilation finishes, click **Download Firmware** (it will be a `.bin` file).

## 4) Flash with QMK Toolbox (Windows)
1. Open **QMK Toolbox**.
2. Load the downloaded `.bin` in the top-right **Open** field.
3. Put the keyboard in bootloader mode (e.g. by the reset key combo or hardware button). For GMMK Pro rev1 the keycombo is space + esc during startup.
4. Ensure the **MCU**/device is detected in Toolbox.
5. Click **Flash** and wait until it completes.

## 5) Save
The json and the compiled binary inside `qmk/` should be updated after any change.

