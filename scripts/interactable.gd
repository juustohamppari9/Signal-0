extends Node3D
class_name Interactable
## Base class for objects the player can interact with (E key).
##
## To add a new interactable:
##   1. Extend this script (or write the two functions below).
##   2. Put the scene root in the "interactable" group.
##   3. Give the root a collision shape so the player's ray can hit it.
##
## The player (scripts/player.gd) calls get_prompt() every frame it aims at the
## object and interact() when E is pressed.


func get_prompt() -> String:
	return "E - Interact"


func interact(_player: Node) -> void:
	pass
