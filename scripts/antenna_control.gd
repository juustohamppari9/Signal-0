extends "res://scripts/interactable.gd"
## Antenna machine (under the mast) and its wall control panel.
##
## Each node reacts differently to E:
##   - Machine cabinet (group "antenna_machine"): toggles antenna power directly.
##     The GUI is NOT reachable from here; the prompt reflects the state
##     (turn on / turn off / locked while the generator is off).
##   - Wall control panel: the only place that opens the antenna control GUI
##     (scenes/antenna_gui.tscn), which talks to the machine's state.
##
## Power dependency: the antenna starts OFF and can only be switched on while
## the site generator (group "generator") is running. If the generator stops,
## the antenna loses power in the same frame.

const GUI_GROUP := "antenna_gui"
const MACHINE_GROUP := "antenna_machine"
const GENERATOR_GROUP := "generator"

const ON_COLOR := Color(0.2, 0.9, 0.3)
const OFF_COLOR := Color(0.9, 0.15, 0.1)

var power_on: bool = false
var channel: int = 1
var signal_pct: int = 60

@onready var _beacon: MeshInstance3D = get_parent().get_node_or_null("Beacon")
@onready var _light: MeshInstance3D = get_node_or_null("MachineLight")


func _ready() -> void:
	# Start unpowered: beacon dark, machine indicator red (machine only; the
	# wall panel has no light of its own).
	if is_in_group(MACHINE_GROUP):
		_apply_power()


func get_prompt() -> String:
	if not is_in_group(MACHINE_GROUP):
		return "E - Antenna control"  # wall panel: opens the GUI
	if power_on:
		return "E - Turn off antenna"
	if generator_running():
		return "E - Turn on antenna"
	return "E - Locked: start the generator"


func interact(_player: Node) -> void:
	if is_in_group(MACHINE_GROUP):
		# Machine cabinet: power switch only, no GUI.
		if set_power(not power_on):
			print("[antenna] power ", "on" if power_on else "off")
		else:
			print("[antenna] power on refused: generator offline")
		return
	# Wall control panel: the one and only entry to the control GUI.
	var gui := get_tree().get_first_node_in_group(GUI_GROUP)
	if gui == null:
		push_warning("antenna control: no node in group '%s'" % GUI_GROUP)
		return
	gui.open(_machine())


## Switches the antenna on/off. Returns true if the state actually changed;
## turning ON is refused (and returns false) while the generator is off.
func set_power(on: bool) -> bool:
	if on and not generator_running():
		return false
	if power_on == on:
		return false
	power_on = on
	_apply_power()
	return true


## True while the site generator (group "generator") is running. If the scene
## has no generator at all the antenna is allowed to power on, so standalone
## test scenes without one are not bricked.
func generator_running() -> bool:
	var gen := get_tree().get_first_node_in_group(GENERATOR_GROUP)
	if gen == null:
		return true
	return gen.get("running") == true


func set_channel(value: int) -> void:
	channel = value


func set_signal(value: int) -> void:
	signal_pct = value


func _machine() -> Node:
	var machine := get_tree().get_first_node_in_group(MACHINE_GROUP)
	return machine if machine != null else self


func _process(_delta: float) -> void:
	# Only the machine owns the power state; the wall panel skips this.
	if not is_in_group(MACHINE_GROUP):
		return
	# Full dependency: losing the generator kills the antenna immediately.
	if power_on and not generator_running():
		power_on = false
		_apply_power()
		print("[antenna] power lost: generator stopped")
	if _beacon == null:
		return
	var blink := Time.get_ticks_msec() % 1000 < 650
	_beacon.visible = power_on and blink


func _apply_power() -> void:
	if _beacon != null and not power_on:
		_beacon.visible = false
	if _light == null:
		return
	var mat := _light.material_override as StandardMaterial3D
	if mat == null and _light.mesh is PrimitiveMesh:
		mat = (_light.mesh as PrimitiveMesh).material as StandardMaterial3D
	if mat != null:
		mat.albedo_color = ON_COLOR if power_on else OFF_COLOR
