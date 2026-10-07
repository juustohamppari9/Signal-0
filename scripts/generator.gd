extends "res://scripts/interactable.gd"
## Maintenance generator next to the building.
## Press E to start / stop it. The indicator light and status label update.

const ON_COLOR := Color(0.25, 1.0, 0.4)
const OFF_COLOR := Color(1.0, 0.25, 0.2)

@onready var indicator: MeshInstance3D = $Indicator
@onready var status_label: Label3D = $StatusLabel

var running: bool = false


func get_prompt() -> String:
	return "E - Stop generator" if running else "E - Start generator"


func interact(_player: Node) -> void:
	running = not running
	_apply_state()
	print("[generator] ", "started" if running else "stopped")


func _apply_state() -> void:
	var material := indicator.material_override as StandardMaterial3D
	if material != null:
		material.albedo_color = ON_COLOR if running else OFF_COLOR
	status_label.text = "RUNNING" if running else "OFF"
