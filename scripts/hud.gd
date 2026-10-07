extends CanvasLayer
## Minimal HUD: crosshair, interaction prompt and control hints.
##
## The node lives in the "hud" group so the player can push prompts into it
## with get_tree().call_group("hud", "set_prompt", text).

@onready var prompt_label: Label = $PromptLabel


func set_prompt(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()
