# SIGNAL 0

First playable prototype of a first-person 3D exploration / maintenance game
made with **Godot 4.7** (Forward Mobile renderer, Jolt physics).

Everything is built from Godot primitive meshes — no imported assets.

## Controls

| Input   | Action                                        |
| ------- | --------------------------------------------- |
| `W A S D` | Move                                          |
| Mouse   | Look (captured on start)                      |
| `Space` | Jump                                          |
| `E`     | Interact with whatever is under the crosshair |
| `Esc`   | Release the mouse (click to capture it again) |

## What is in the prototype

- First-person player (`CharacterBody3D`) with movement, mouse look, jump, interaction ray.
- Flat 160 x 160 m terrain.
- Forest of 34 primitive trees (cylinder trunk + cone canopy).
- Lattice radio mast with antenna and beacon.
- Maintenance building you can walk into (doorway at the front).
- Generator next to the building: `E` starts / stops it (indicator light + label change).
- Radio inside the building: `E` tunes the next channel (label above it changes).
- Minimal HUD: crosshair, interaction prompt, control hints.

## Project structure

```
project.godot              Project config + input actions (move/jump/interact)
scenes/
  main.tscn                World: terrain, sun, sky, props, forest, player, HUD
  player.tscn              First-person player (capsule + head + camera + ray)
  hud.tscn                 Crosshair, prompt label, controls hint
  props/
    tree.tscn              Primitive tree (instance it as many times as you like)
    radio_tower.tscn       Lattice mast + antenna + beacon
    maintenance_building.tscn  Walls, floor, roof, doorway (enterable)
    generator.tscn         Interactable generator
    radio.tscn             Interactable radio
scripts/
  player.gd                Movement, mouse look, jump, interaction
  interactable.gd          Base class for interactable objects (get_prompt / interact)
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
  `move_back`, `move_left`, `move_right`, `jump`, `interact`).
- **Tuning:** the player exports `move_speed`, `jump_velocity`,
  `mouse_sensitivity` and `interact_distance` in the inspector.
- **World layout:** every prop in `scenes/main.tscn` is an ordinary instance —
  move, duplicate or delete them directly in the editor.
