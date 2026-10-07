extends "res://scripts/interactable.gd"
## Simple radio inside the maintenance building.
## Press E to tune to the next channel.

const CHANNELS: Array[String] = [
	"88.1  STATIC",
	"96.3  WEATHER",
	"103.9  MUSIC",
]

@onready var status_label: Label3D = $StatusLabel

var channel: int = 0


func get_prompt() -> String:
	return "E - Tune radio"


func interact(_player: Node) -> void:
	channel = (channel + 1) % CHANNELS.size()
	status_label.text = CHANNELS[channel]
	print("[radio] tuned to ", CHANNELS[channel])
