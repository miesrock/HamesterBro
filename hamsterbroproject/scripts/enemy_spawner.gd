extends Node3D
class_name EnemySpawner

const EnemySceneScript := preload("res://scripts/enemy.gd")

@export var player_path: NodePath
@export_range(20, 300, 1) var target_count: int = 120
@export var spawn_min_radius: float = 18.0
@export var spawn_max_radius: float = 28.0
@export var refill_per_tick: int = 12

var _player: Node3D
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_player = get_node_or_null(player_path) as Node3D
	if _player == null:
		push_error("EnemySpawner needs a valid player_path.")
		set_physics_process(false)


func _physics_process(_delta: float) -> void:
	var enemy_count: int = get_tree().get_nodes_in_group("enemies").size()
	var spawn_count: int = mini(refill_per_tick, target_count - enemy_count)
	for _index: int in spawn_count:
		_spawn_enemy()


func _spawn_enemy() -> void:
	if _player == null:
		return

	var angle: float = _rng.randf_range(0.0, TAU)
	var radius: float = _rng.randf_range(spawn_min_radius, spawn_max_radius)
	var offset := Vector3(cos(angle) * radius, 0.35, sin(angle) * radius)

	var enemy := EnemySceneScript.new()
	enemy.target = _player
	add_child(enemy)
	enemy.global_position = _player.global_position + offset
