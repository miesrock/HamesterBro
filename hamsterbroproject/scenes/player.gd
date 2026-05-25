extends CharacterBody3D

## Emitted after health is clamped into [0, max_health].
signal health_changed(current: int, maximum: int)
## Emitted after experience changes or the next level threshold changes.
signal experience_changed(current: int, required: int, level: int)
## Emitted once for every gained level.
signal level_up(new_level: int)
## Emitted once when health reaches zero.
signal died

@export var move_speed: float = 4.0
@export var jump_velocity: float = 7.0
@export var gravity: float = 22.0
@export var max_health: int = 200
@export var starting_health: int = 200
@export var starting_experience_to_next_level: int = 10
@export var visual_pivot_path: NodePath = ^"VisualPivot"
@export var visual_model_path: NodePath = ^"VisualPivot/HamsterModel"
@export var visual_yaw_offset_degrees: float = 180.0

var current_health: int = 200
var level: int = 1
var experience: int = 0
var experience_to_next_level: int = 10
var _visual_pivot: Node3D
var _visual_model: Node3D
var _ground_y: float = 0.0
var _is_dead: bool = false


func _ready() -> void:
	add_to_group("player")
	_ground_y = global_position.y
	current_health = clampi(starting_health, 0, max_health)
	experience_to_next_level = max(1, starting_experience_to_next_level)

	var placeholder := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if placeholder != null:
		placeholder.visible = false

	var generated_visual := get_node_or_null("HamsterVisual")
	if generated_visual != null:
		generated_visual.queue_free()

	_visual_pivot = get_node_or_null(visual_pivot_path) as Node3D
	_visual_model = get_node_or_null(visual_model_path) as Node3D
	if _visual_model == null:
		_visual_model = get_node_or_null("Sketchfab_Scene") as Node3D

	if _visual_pivot == null:
		_visual_pivot = _visual_model

	if _visual_model == null:
		push_warning("Player has no HamsterModel visual node to rotate.")

	health_changed.emit(current_health, max_health)
	experience_changed.emit(experience, experience_to_next_level, level)


func _physics_process(delta: float) -> void:
	var input_dir := Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	velocity.x = input_dir.x * move_speed
	velocity.z = input_dir.z * move_speed

	if _is_grounded():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		elif velocity.y < 0.0:
			velocity.y = 0.0
	else:
		velocity.y -= gravity * delta

	move_and_slide()
	if global_position.y < _ground_y:
		global_position.y = _ground_y
		velocity.y = 0.0

	if input_dir.length_squared() > 0.0:
		_face_move_direction(input_dir)


func _face_move_direction(input_dir: Vector3) -> void:
	if _visual_pivot == null:
		return

	_visual_pivot.look_at(_visual_pivot.global_position + input_dir, Vector3.UP)
	if not is_zero_approx(visual_yaw_offset_degrees):
		_visual_pivot.rotate_y(deg_to_rad(visual_yaw_offset_degrees))


func add_experience(value: int) -> void:
	if value <= 0:
		return

	experience += value
	while experience >= experience_to_next_level:
		experience -= experience_to_next_level
		level += 1
		experience_to_next_level = _get_next_experience_requirement()
		level_up.emit(level)

	experience_changed.emit(experience, experience_to_next_level, level)


func take_damage(amount: int) -> void:
	if amount <= 0 or _is_dead:
		return

	current_health = clampi(current_health - amount, 0, max_health)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		_is_dead = true
		died.emit()


func heal(amount: int) -> void:
	if amount <= 0 or _is_dead:
		return

	current_health = clampi(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)


func increase_max_health(amount: int, heal_amount: int) -> void:
	if amount <= 0:
		return

	max_health += amount
	if heal_amount > 0 and not _is_dead:
		current_health = clampi(current_health + heal_amount, 0, max_health)
	health_changed.emit(current_health, max_health)


func _is_grounded() -> bool:
	return global_position.y <= _ground_y + 0.01 and velocity.y <= 0.0


func _get_next_experience_requirement() -> int:
	return int(ceil(float(experience_to_next_level) * 1.35 + 4.0))
