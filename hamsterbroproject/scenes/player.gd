extends CharacterBody3D

@export var move_speed: float = 4.0
@export var visual_pivot_path: NodePath = ^"VisualPivot"
@export var visual_model_path: NodePath = ^"VisualPivot/HamsterModel"
@export var visual_yaw_offset_degrees: float = 180.0

var _visual_pivot: Node3D
var _visual_model: Node3D


func _ready() -> void:
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
	velocity.y = 0

	move_and_slide()

	if input_dir.length_squared() > 0.0:
		_face_move_direction(input_dir)


func _face_move_direction(input_dir: Vector3) -> void:
	if _visual_pivot == null:
		return

	_visual_pivot.look_at(_visual_pivot.global_position + input_dir, Vector3.UP)
	if not is_zero_approx(visual_yaw_offset_degrees):
		_visual_pivot.rotate_y(deg_to_rad(visual_yaw_offset_degrees))
