extends Area3D
class_name ExperienceOrb

@export var experience_value: int = 1
@export var attract_speed: float = 12.0
@export var attract_distance: float = 4.0
@export var collect_distance: float = 0.55
@export var hover_height: float = 0.35

var player: Node3D
var is_attracting: bool = false

var _bob_time: float = 0.0


func _ready() -> void:
	add_to_group("xp_orb")
	player = get_tree().get_first_node_in_group("player") as Node3D
	body_entered.connect(_on_body_entered)
	_build_visual()
	_build_collision()


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	_bob_time += delta
	var target_position: Vector3 = player.global_position + Vector3.UP * hover_height
	var distance: float = global_position.distance_to(target_position)

	if distance <= attract_distance:
		is_attracting = true

	if is_attracting:
		var direction: Vector3 = target_position - global_position
		if direction.length_squared() > 0.001:
			var speed: float = attract_speed
			if distance < 1.5:
				speed *= 1.8
			global_position += direction.normalized() * speed * delta

	if distance <= collect_distance:
		_collect(player)

	rotation.y += delta * 3.5


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_collect(body)


func _collect(body: Node) -> void:
	if body.has_method("add_experience"):
		body.call("add_experience", experience_value)

	queue_free()


func _build_visual() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.95, 1.0, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.2, 0.95, 1.0, 1.0)
	material.emission_energy_multiplier = 1.8
	material.roughness = 0.25

	var core := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.18
	mesh.height = 0.18
	core.mesh = mesh
	core.material_override = material
	add_child(core)

	var ring := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.16
	ring_mesh.outer_radius = 0.22
	ring.mesh = ring_mesh
	ring.material_override = material
	ring.rotation_degrees.x = 90.0
	add_child(ring)


func _build_collision() -> void:
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.45
	collision.shape = shape
	add_child(collision)
