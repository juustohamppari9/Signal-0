# SIGNAL 0

First playable prototype of a first-person 3D exploration / maintenance game
made with **Godot 4.7** (Forward Mobile renderer, Jolt physics).

Everything is built from Godot primitive meshes — no imported assets.

## Controls

| Input   | Action                                        |
| ------- | --------------------------------------------- |
| `W A S D` | Move                                          |
| `Shift` | Sprint (1.8x move speed)                      |
| Mouse   | Look (captured on start)                      |
| `Space` | Jump                                          |
| `E`     | Interact with whatever is under the crosshair |
| `Esc`   | Release the mouse (click to capture it again) |

## What is in the prototype

- First-person player (`CharacterBody3D`) with movement, sprint, mouse look, jump, interaction ray.
- Flat 160 x 160 m terrain.
- Forest of 34 primitive trees (cylinder trunk + cone canopy).
- Lattice radio mast with an antenna pole running from the ground to the beacon,
  standing right next to the building. A transmitter machine sits at its base, and
  the hitbox matches the visible pad and four legs (you can walk between the legs —
  no invisible wall box). `E` on the machine is a **power switch only**: the prompt
  shows the state ("E - Turn on antenna" / "E - Turn off antenna" / "E - Locked:
  start the generator") and it never opens a menu.
- Control panel mounted on the tower leg next to the machine: the **only** place
  that opens the antenna control GUI (POWER / TUNE / BOOST, pauses the game,
  `Esc` or CLOSE resumes).
  POWER also toggles the beacon blink and the machine indicator light.
  Power is wired to the generator: the antenna starts **off**, POWER stays locked
  (greyed button, red "GENERATOR OFFLINE" status) until the generator is running,
  and stopping the generator kills the antenna power immediately.
- Maintenance building you can walk into (doorway at the front), furnished with a
  table and a couple of crates, plus a framed glass window in the wall — from
  outside you can see straight through to the table, crates and the far doorway.
- Generator next to the tower: `E` starts / stops it (indicator light + label change).
  It feeds the antenna — nothing on the mast powers up while the generator is off.
- Cables strung in the air on two wooden poles: out of the transmitter machine, up
  to the generator pole, down onto the generator, across to the house pole and into
  the building wall.
- Radio on the table inside the building: `E` tunes the next channel (label above it changes).
- Minimal HUD: crosshair, interaction prompt, control hints.

## Project structure

```
project.godot              Project config + input actions (move/sprint/jump/interact)
scenes/
  main.tscn                World: terrain, sun, sky, props, forest, player, HUD
  player.tscn              First-person player (capsule + head + camera + ray)
  hud.tscn                 Crosshair, prompt label, controls hint
  antenna_gui.tscn         Antenna control GUI opened from the tower control panel
  props/
    tree.tscn              Primitive tree (instance it as many times as you like)
    radio_tower.tscn       Lattice mast + pad/leg hitbox + base machine + control panel + beacon
    maintenance_building.tscn  Walls, floor, roof, doorway + framed glass window (enterable)
    pole.tscn              Wooden pole with a crossarm; carries the cables in the air
    generator.tscn         Interactable generator
    radio.tscn             Interactable radio
    table.tscn             Primitive table (radio sits on top of it)
    crate.tscn             Primitive crate (two of them inside the building)
scripts/
  player.gd                Movement, mouse look, jump, interaction
  interactable.gd          Base class for interactable objects (get_prompt / interact)
  antenna_control.gd       Machine = power switch only; control panel opens the GUI,
                           beacon blink, generator dependency (refuse on / auto-cut)
  antenna_gui.gd           GUI logic: open/close + pause, POWER/TUNE/BOOST handlers,
                           generator status line + POWER lockout
  generator.gd             Generator behaviour
  radio.gd                 Radio behaviour
  hud.gd                   set_prompt(text) used by the player
```

## Running the game

1. Open **Godot 4.7** (or newer Godot 4.x).
2. On the Project Manager screen choose **Import** and select this folder's
   `project.godot` (skip this if the project is already in your list).
3. Press **F5** (or the ▶ button) to run. The main scene is `scenes/main.tscn`.

From the command line:

```
godot --path . 
```

## Extending it

- **New interactable:** extend `scripts/interactable.gd`, implement `get_prompt()`
  and `interact()`, put the scene root in the `interactable` group and give it a
  collision shape. The player's ray does the rest.
- **Input:** change bindings in *Project Settings -> Input Map* (`move_forward`,
  `move_back`, `move_left`, `move_right`, `sprint`, `jump`, `interact`).
- **Tuning:** the player exports `move_speed`, `sprint_multiplier`, `jump_velocity`,
  `mouse_sensitivity` and `interact_distance` in the inspector.
- **World layout:** every prop in `scenes/main.tscn` is an ordinary instance —
  move, duplicate or delete them directly in the editor.
