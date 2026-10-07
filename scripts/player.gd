extends CharacterBody3D
## First-person player controller for SIGNAL 0.
##
## Controls (defined in Project Settings > Input Map):
##   WASD        - move
##   Mouse       - look
##   Space       - jump
##   E           - interact with whatever is under the crosshair
##   Esc / Click - release / capture the mouse

@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.0022
@export var interact_distance: float = 3.0

const ACCELERATION: float = 14.0    # Ground acceleration (snappy).
const AIR_ACCELERATION: float = 4.0 # Airborne acceleration (floatier).
const MAX_PITCH: float = 1.5        # ~86 degrees, stops the camera flipping over.

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay

var _gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))
var _prompt: String = ""


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	interact_ray.target_position = Vector3(0.0, 0.0, -interact_distance)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_apply_look(event.relative)
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("interact"):
		var target := _get_interactable()
		if target != null and target.has_method("interact"):
			target.interact(self)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_apply_movement(delta)
	move_and_slide()
	_update_prompt()


# --- Movement -----------------------------------------------------------------


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	velocity.y -= _gravity * delta


func _apply_movement(delta: float) -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()

	var acceleration := ACCELERATION if is_on_floor() else AIR_ACCELERATION
	var target := direction * move_speed
	velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target.z, acceleration * delta)


func _apply_look(relative: Vector2) -> void:
	rotate_y(-relative.x * mouse_sensitivity)
	head.rotate_x(-relative.y * mouse_sensitivity)
	head.rotation.x = clampf(head.rotation.x, -MAX_PITCH, MAX_PITCH)


# --- Interaction ---------------------------------------------------------------
# Interactables are StaticBody3D props in the "interactable" group
# (see scripts/interactable.gd).


func _get_interactable() -> Node:
	if not interact_ray.is_colliding():
		return null
	var collider := interact_ray.get_collider()
	if collider is Node and collider.is_in_group("interactable"):
		return collider
	return null


func _update_prompt() -> void:
	var target := _get_interactable()
	var next := ""
	if target != null and target.has_method("get_prompt"):
		next = target.get_prompt()
	if next == _prompt:
		return
	_prompt = next
	get_tree().call_group("hud", "set_prompt", next)
