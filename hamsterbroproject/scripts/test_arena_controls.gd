extends CanvasLayer
class_name TestArenaControls

const ExperienceOrbScript := preload("res://scripts/experience_orb.gd")
const DamageTextScript := preload("res://scripts/damage_text.gd")

@export var player_path: NodePath
@export var enemy_spawner_path: NodePath
@export var combat_director_path: NodePath

var _player: Node3D
var _enemy_spawner: Node
var _combat_director: Node

var _perf_label: Label
var _status_label: Label
var _status_time: float = 0.0


func _ready() -> void:
	_player = get_node_or_null(player_path) as Node3D
	_enemy_spawner = get_node_or_null(enemy_spawner_path)
	_combat_director = get_node_or_null(combat_director_path)
	_build_ui()


func _process(delta: float) -> void:
	if _perf_label != null:
		var fps: int = Engine.get_frames_per_second()
		var frame_ms: float = 0.0
		if fps > 0:
			frame_ms = 1000.0 / float(fps)
		_perf_label.text = "PERF\nFPS: %d\nFRAME: %.2f ms\nENEMIES: %d\nORBS: %d" % [
			fps,
			frame_ms,
			get_tree().get_nodes_in_group("enemies").size(),
			get_tree().get_nodes_in_group("xp_orb").size(),
		]

	if _status_time > 0.0:
		_status_time -= delta
		if _status_time <= 0.0 and _status_label != null:
			_status_label.text = ""


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var panel := PanelContainer.new()
	panel.position = Vector2(14, 258)
	panel.custom_minimum_size = Vector2(230, 214)
	root.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.11, 0.13, 0.86)
	style.border_color = Color(0.43, 0.78, 0.92, 0.95)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(body)

	var title := Label.new()
	title.text = "TEST ARENA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.label_settings = _label_settings(18, Color(0.95, 0.94, 0.82, 1.0), 3)
	body.add_child(title)

	body.add_child(_make_button("刷怪 +10", _on_spawn_pressed))
	body.add_child(_make_button("伤害测试", _on_damage_pressed))
	body.add_child(_make_button("经验球 x6", _on_orb_pressed))

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.custom_minimum_size = Vector2(206, 42)
	_status_label.label_settings = _label_settings(12, Color(0.74, 0.94, 1.0, 1.0), 2)
	body.add_child(_status_label)

	_perf_label = Label.new()
	_perf_label.position = Vector2(972, 8)
	_perf_label.label_settings = _label_settings(14, Color(0.95, 0.94, 0.82, 1.0), 3)
	root.add_child(_perf_label)


func _make_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(206, 34)
	button.pressed.connect(callback)
	return button


func _on_spawn_pressed() -> void:
	if _enemy_spawner == null or not _enemy_spawner.has_method("_spawn_enemy"):
		_set_status("刷怪器未连接")
		return

	for _i: int in 10:
		_enemy_spawner.call("_spawn_enemy")
	_set_status("已手动刷怪 +10")


func _on_damage_pressed() -> void:
	if _player == null:
		_set_status("玩家未连接")
		return

	var nearest := _find_nearest_enemy()
	if nearest == null:
		if _enemy_spawner != null and _enemy_spawner.has_method("_spawn_enemy"):
			_enemy_spawner.call("_spawn_enemy")
			nearest = _find_nearest_enemy()

	if nearest != null and nearest.has_method("take_hit"):
		var dir := nearest.global_position - _player.global_position
		dir.y = 0.0
		if dir.length_squared() < 0.001:
			dir = Vector3.FORWARD
		nearest.call("take_hit", dir.normalized())
		_show_damage_text(nearest.global_position + Vector3(0.0, 1.1, 0.0), "TEST HIT")
		_set_status("伤害测试完成")
		return

	_set_status("没有可测试敌人")


func _on_orb_pressed() -> void:
	if _player == null:
		_set_status("玩家未连接")
		return

	for idx: int in 6:
		var orb := ExperienceOrbScript.new()
		add_child(orb)
		var spread := Vector3(randf_range(-1.5, 1.5), 0.35, randf_range(-1.5, 1.5))
		orb.global_position = _player.global_position + spread + Vector3(0.0, 0.1 * idx, 0.0)

	_set_status("经验球已生成 x6")


func _show_damage_text(at: Vector3, text: String) -> void:
	if _combat_director == null:
		return

	var damage_text := DamageTextScript.new()
	_combat_director.add_child(damage_text)
	damage_text.configure(text, at, Color(1.0, 0.42, 0.2, 1.0))


func _find_nearest_enemy() -> Node3D:
	if _player == null:
		return null

	var nearest: Node3D = null
	var nearest_distance_sq: float = INF
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Node3D
		if enemy == null or not is_instance_valid(enemy):
			continue

		var distance_sq := enemy.global_position.distance_squared_to(_player.global_position)
		if distance_sq < nearest_distance_sq:
			nearest = enemy
			nearest_distance_sq = distance_sq

	return nearest


func _set_status(text: String) -> void:
	if _status_label == null:
		return
	_status_label.text = text
	_status_time = 2.3


func _label_settings(font_size: int, color: Color, outline_size: int) -> LabelSettings:
	var settings := LabelSettings.new()
	settings.font_size = font_size
	settings.font_color = color
	settings.outline_size = outline_size
	settings.outline_color = Color(0.0, 0.0, 0.0, 0.9)
	return settings
