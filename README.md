# Minetest Mod: Aircraft Color Trail

By Luffy0805
Version: 1.0.0
License: MIT

---

## Description

This mod adds customizable colored smoke trails for the aircraft from APercy.

Players can toggle colorful smoke trails during flight using a special remote control, with multiple display modes:

* Mode 1: Central rear jet
* Mode 2: Symmetrical side jets
* Mode 3: Dual-colored side jets (uses two dyes)

The mod supports dye consumption, animated smoke particles, and per-aircraft configuration.

---

## Compatibility

This mod is compatible with most aircraft by APercy, such as:

* PA-28
* Supercub, Superduck Hydroplane
* JU 52 3M, JU 52 3M Hydroplane
* F1 Camel and Albatros from the WW1 mod
* Savoia S21

It does **not** modify these aircraft mods. All interactions are handled externally, making installation and updates seamless.

---

## Installation

1. Copy the mod folder into the `mods/` directory of your Minetest installation.
2. Enable the mod for your world.
3. Make sure the aircraft mods you want to use are installed and active.

---

## Usage

* Craft or obtain the `Color Smoke Remote` (`pa28_color_trail:remote`).
* Equip it in hand.
* Left-click to toggle the smoke.
* Use `AUX1` or `SNEAK` + left-click to change mode.
* Place dyes in the aircraft's inventory (right-click on the aircraft, if supported).

### Smoke Modes:

* **Mode 1** – Central trail, consumes 1 dye every 10 seconds
* **Mode 2** – Side jets, consumes 1 dye every 5 seconds
* **Mode 3** – Dual-colored side jets, 1 dye per side every 10 seconds

Smoke only appears during flight.

---

## Manual

A manual (`aircraft_color_trail:manual`) is included in the mod. Use it to get in-game instructions about the modes and usage.

---

## Customization

The `init.lua` file contains an `offset_config` table for all supported aircraft, defining:

```lua
["Aircraft Name"] = {
    mode1 = {x = 0, y = 0, z = -2},  -- central mode offset
    mode2 = {x = 3, y = -0.2},      -- side jets offset
    mode3 = {x = 3, y = -0.2},
}
```

You can add your own aircraft by extending this table.

---

## Known Limitations

* This mod relies on external inventory access (`_inv`) provided by APercy's "Airutils" mod.
* If an aircraft is unsupported or a config is missing, a warning is shown in chat.

---

## Credits

* Original aircraft mods by APercy
* Smoke system and integration by Luffy0805

---

## End.
