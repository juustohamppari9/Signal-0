extends Control
## Antenna control GUI, opened with E on the wall control panel (the only
## entry point — the machine cabinet itself is a plain power switch).
## Pauses the game while open; Esc or the CLOSE button dismisses it.

@onready var _power_label: Label = $Panel/Layout/PowerLabel
@onready var _channel_label: Label = $Panel/Layout/ChannelLabel
@onready var _signal_label: Label = $Panel/Layout/SignalLabel
@onready var _status_label: Label = $Panel/Layout/StatusLabel
@onready var _power_button: Button = $Panel/Layout/Buttons/PowerButton

var _machine: Node = null


func _ready() -> void:
	visible = false
	$Panel/Layout/Buttons/PowerButton.pressed.connect(_on_power)
	$Panel/Layout/Buttons/TuneButton.pressed.connect(_on_tune)
	$Panel/Layout/Buttons/BoostButton.pressed.connect(_on_boost)
	$Panel/Layout/Buttons/CloseButton.pressed.connect(close)


func open(machine: Node) -> void:
	_machine = machine
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().call_group("hud", "set_prompt", "")
	_refresh()


func close() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _on_power() -> void:
	if _machine != null and not _machine.set_power(not _machine.power_on):
		# Refused: the generator is offline (see antenna_control.set_power).
		print("[antenna] power on refused: generator offline")
	_refresh()


func _on_tune() -> void:
	if _machine != null:
		_machine.set_channel(_machine.channel % 4 + 1)
	_refresh()


func _on_boost() -> void:
	if _machine != null:
		var pct: int = _machine.signal_pct + 15
		_machine.set_signal(10 if pct > 100 else pct)
	_refresh()


func _refresh() -> void:
	if _machine == null:
		return
	_power_label.text = "POWER    : " + ("ON" if _machine.power_on else "OFF")
	_channel_label.text = "CHANNEL  : %d" % _machine.channel
	var filled := int(round(_machine.signal_pct / 10.0))
	_signal_label.text = "SIGNAL   : [%s%s] %d%%" % [
		"#".repeat(filled), "-".repeat(10 - filled), _machine.signal_pct,
	]
	# Power is locked while the site generator is off: explain + grey the button.
	var gen_ok: bool = _machine.generator_running()
	_power_button.disabled = not gen_ok and not _machine.power_on
	if not gen_ok:
		_status_label.text = "GENERATOR OFFLINE - POWER LOCKED"
		_status_label.add_theme_color_override("font_color", Color(1, 0.4, 0.3))
	elif not _machine.power_on:
		_status_label.text = "GENERATOR ONLINE - READY"
		_status_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.6))
	else:
		_status_label.text = "TRANSMITTING"
		_status_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.6))
