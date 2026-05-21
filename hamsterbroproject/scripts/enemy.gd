extends CharacterBody3D
class_name Enemy

@export var move_speed: float = 2.1
@export var knockback_decay: float = 10.0
@export var visual_scale: float = 0.72

var target: Node3D
var _knockback: Vector3 = Vector3.ZERO


func _ready() -> void:
	add_to_group("enemies")
	_build_visual()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	var to_target: Vector3 = target.global_position - global_position
	to_target.y = 0.0
	var desired: Vector3 = Vector3.ZERO
	if to_target.length_squared() > 0.01:
		desired = to_target.normalized() * move_speed
		look_at(global_position + to_target.normalized(), Vector3.UP)

	velocity.x = desired.x + _knockback.x
	velocity.z = desired.z + _knockback.z
	velocity.y = 0.0
	move_and_slide()

	_knockback = _knockback.move_toward(Vector3.ZERO, knockback_decay * delta)


func take_hit(hit_direction: Vector3) -> void:
	_knockback = hit_direction.normalized() * 4.5
	queue_free()


func _build_visual() -> void:
	var body_material := StandardMaterial3D.new()
	body_material.albedo_color = Color(0.92, 0.91, 0.86, 1.0)
	body_material.roughness = 0.9

	var outline_material := StandardMaterial3D.new()
	outline_material.albedo_color = Color(0.06, 0.065, 0.07, 1.0)
	outline_material.roughness = 1.0

	var outline := MeshInstance3D.new()
	var outline_mesh := CapsuleMesh.new()
	outline_mesh.radius = 0.28
	outline_mesh.height = 0.72
	outline.mesh = outline_mesh
	outline.material_override = outline_material
	outline.scale = Vector3(1.18, 0.82, 1.18) * visual_scale
	add_child(outline)

	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.25
	body_mesh.height = 0.68
	body.mesh = body_mesh
	body.material_override = body_material
	body.rotation_degrees.x = 90.0
	body.position.y = 0.13
	body.scale = Vector3.ONE * visual_scale
	add_child(body)

	var shell := MeshInstance3D.new()
	var shell_mesh := SphereMesh.new()
	shell_mesh.radius = 0.18
	shell_mesh.height = 0.24
	shell.mesh = shell_mesh
	shell.material_override = outline_material
	shell.position = Vector3(0.0, 0.18, -0.17)
	shell.scale = Vector3(1.0, 0.55, 0.7) * visual_scale
	add_child(shell)
