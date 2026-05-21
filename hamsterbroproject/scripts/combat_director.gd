extends Node3D
class_name CombatDirector

const BulletSceneScript := preload("res://scripts/bullet.gd")
const DamageTextSceneScript := preload("res://scripts/damage_text.gd")

@export var player_path: NodePath
@export var muzzle_path: NodePath
@export var fire_interval: float = 0.14
@export var burst_count: int = 3
@export var spread_degrees: float = 10.0
@export var damage_text_interval: float = 0.08

var _player: Node3D
var _muzzle: Node3D
var _fire_timer: float = 0.0
var _damage_text_timer: float = 0.0
var _color_index: int = 0
var _rng := RandomNumberGenerator.new()

const BULLET_COLORS: Array[Color] = [
	Color(0.2, 1.0, 1.0, 1.0),
	Color(1.0, 0.2, 0.95, 1.0),
	Color(1.0, 0.88, 0.12, 1.0),
	Color(0.32, 1.0, 0.28, 1.0),
	Color(1.0, 0.45, 0.12, 1.0),
]

const DAMAGE_WORDS: Array[String] = [
	"999!",
	"777!",
	"1337!",
	"OUCH!",
	"CRIT-HAM!",
]


func _ready() -> void:
	_rng.randomize()
	_player = get_node_or_null(player_path) as Node3D
	if _player == null:
		push_error("CombatDirector needs a valid player_path.")
		set_physics_process(false)
		return

	if not muzzle_path.is_empty:
		_muzzle = get_node_or_null(muzzle_path) as Node3D

	if _muzzle == null:
		_muzzle = _player.get_node_or_null("VisualPivot/Muzzle") as Node3D


func _physics_process(delta: float) -> void:
	_fire_timer -= delta
	_damage_text_timer -= delta
	if _fire_timer > 0.0:
		return

	var target := _find_nearest_enemy()
	if target == null:
		return

	_fire_timer = fire_interval
	_fire_burst(target)


func _find_nearest_enemy() -> Node3D:
	if _player == null:
		return null

	var nearest: Node3D = null
	var nearest_distance_sq: float = INF
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Node3D
		if enemy == null or not is_instance_valid(enemy):
			continue

		var distance_sq: float = _player.global_position.distance_squared_to(enemy.global_position)
		if distance_sq < nearest_distance_sq:
			nearest = enemy
			nearest_distance_sq = distance_sq

	return nearest


func _fire_burst(target: Node3D) -> void:
	var base_direction: Vector3 = target.global_position - _player.global_position
	base_direction.y = 0.0
	if base_direction.length_squared() <= 0.01:
		base_direction = -_player.global_transform.basis.z
	base_direction = base_direction.normalized()

	var start_position: Vector3 = _get_muzzle_position(base_direction)
	var half_spread: float = spread_degrees * 0.5
	for index: int in burst_count:
		var t: float = 0.5
		if burst_count > 1:
			t = float(index) / float(burst_count - 1)

		var yaw: float = deg_to_rad(lerp(-half_spread, half_spread, t))
		var direction: Vector3 = base_direction.rotated(Vector3.UP, yaw).normalized()
		var bullet := BulletSceneScript.new()
		var color: Color = BULLET_COLORS[_color_index % BULLET_COLORS.size()]
		_color_index += 1
		bullet.configure(start_position + Vector3.UP * (0.04 * index), direction, color)
		add_child(bullet)
		bullet.enemy_hit.connect(_on_bullet_enemy_hit)


func _get_muzzle_position(base_direction: Vector3) -> Vector3:
	if _muzzle != null and is_instance_valid(_muzzle):
		return _muzzle.global_position

	return _player.global_position + Vector3.UP * 0.9 + base_direction * 0.9


func _on_bullet_enemy_hit(_enemy: Node3D, hit_position: Vector3) -> void:
	if _damage_text_timer > 0.0:
		_spawn_hit_spark(hit_position)
		return

	_damage_text_timer = damage_text_interval
	var text := DamageTextSceneScript.new()
	var word: String = DAMAGE_WORDS[_rng.randi_range(0, DAMAGE_WORDS.size() - 1)]
	var color := Color(1.0, 0.8, 0.18, 1.0)
	if word == "OUCH!":
		color = Color(0.98, 0.98, 0.92, 1.0)
	elif word == "CRIT-HAM!":
		color = Color(1.0, 0.34, 0.18, 1.0)
	add_child(text)
	text.configure(word, hit_position + Vector3(0.0, 0.95, 0.0), color)

	_spawn_hit_spark(hit_position)


func _spawn_hit_spark(hit_position: Vector3) -> void:
	for index: int in 3:
		var spark := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.09, 0.09, 0.42)
		spark.mesh = mesh

		var material := StandardMaterial3D.new()
		var color: Color = BULLET_COLORS[(_color_index + index) % BULLET_COLORS.size()]
		material.albedo_color = color
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 2.0
		spark.material_override = material
		spark.rotation_degrees = Vector3(_rng.randf_range(-35.0, 35.0), _rng.randf_range(0.0, 360.0), _rng.randf_range(-35.0, 35.0))
		add_child(spark)
		spark.global_position = hit_position + Vector3.UP * 0.65

		var tween := create_tween()
		tween.tween_property(spark, "position", spark.position + Vector3(_rng.randf_range(-0.55, 0.55), _rng.randf_range(0.15, 0.75), _rng.randf_range(-0.55, 0.55)), 0.16)
		tween.parallel().tween_property(spark, "scale", Vector3.ZERO, 0.16)
		tween.tween_callback(spark.queue_free)
