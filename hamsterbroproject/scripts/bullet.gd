extends Node3D
class_name RainbowBullet

signal enemy_hit(enemy: Node3D, hit_position: Vector3)

@export var speed: float = 20.0
@export var lifetime: float = 0.72
@export var hit_radius: float = 0.55

var direction: Vector3 = Vector3.FORWARD
var bullet_color: Color = Color.CYAN
var _age: float = 0.0


func _ready() -> void:
	_build_visual()
	if direction.length_squared() > 0.0:
		look_at(global_position + direction, Vector3.UP)


func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
		return

	global_position += direction.normalized() * speed * delta
	_check_enemy_hit()


func configure(start_position: Vector3, shoot_direction: Vector3, color: Color) -> void:
	if is_inside_tree():
		global_position = start_position
	else:
		position = start_position
	direction = shoot_direction.normalized()
	bullet_color = color
	if is_inside_tree() and direction.length_squared() > 0.0:
		look_at(global_position + direction, Vector3.UP)


func _check_enemy_hit() -> void:
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Node3D
		if enemy == null or not is_instance_valid(enemy):
			continue

		var flat_distance := Vector2(global_position.x - enemy.global_position.x, global_position.z - enemy.global_position.z).length()
		if flat_distance <= hit_radius:
			enemy_hit.emit(enemy, enemy.global_position)
			if enemy.has_method("take_hit"):
				enemy.call("take_hit", direction)
			queue_free()
			return


func _build_visual() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = bullet_color
	material.emission_enabled = true
	material.emission = bullet_color
	material.emission_energy_multiplier = 2.5
	material.roughness = 0.35

	var core := MeshInstance3D.new()
	var core_mesh := BoxMesh.new()
	core_mesh.size = Vector3(0.18, 0.18, 1.7)
	core.mesh = core_mesh
	core.material_override = material
	add_child(core)

	var glow := MeshInstance3D.new()
	var glow_mesh := SphereMesh.new()
	glow_mesh.radius = 0.2
	glow_mesh.height = 0.2
	glow.mesh = glow_mesh
	glow.material_override = material
	glow.position.z = -0.42
	glow.scale = Vector3(1.0, 1.0, 1.8)
	add_child(glow)
