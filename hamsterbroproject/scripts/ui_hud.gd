extends Control
class_name HamsterHUD

var _fps_label: Label
var _enemy_label: Label
var _health_label: Label
var _experience_label: Label
var _health_bar: ProgressBar
var _experience_bar: ProgressBar
var _debug_nodes: Array[CanvasItem] = []
var _player: Node
var _spawner: Node
var _debug_visible: bool = true


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()


func _process(_delta: float) -> void:
	if _fps_label != null:
		_fps_label.text = "FPS: %d\nDEBUG VIEW: %s\n\"JUICE\" SETTING: MAX" % [
			Engine.get_frames_per_second(),
			"ACTIVE" if _debug_visible else "HIDDEN",
		]
	if _enemy_label != null:
		var target_count: int = 120
		if _spawner != null:
			target_count = int(_spawner.get("target_count"))
		_enemy_label.text = "DEBUG UI\nFPS: %d\nDEBUG VIEW: %s\n\"JUICE\" SETTING: VISUAL OVERLOAD\nENEMY COUNT: %d / %d" % [
			Engine.get_frames_per_second(),
			"ACTIVE" if _debug_visible else "HIDDEN",
			get_tree().get_nodes_in_group("enemies").size(),
			target_count,
		]


func set_spawner(spawner: Node) -> void:
	_spawner = spawner


func set_player(player: Node) -> void:
	_player = player
	if _player == null:
		return

	if _player.has_signal("health_changed"):
		_player.connect("health_changed", Callable(self, "_on_player_health_changed"))
	if _player.has_signal("experience_changed"):
		_player.connect("experience_changed", Callable(self, "_on_player_experience_changed"))
	if _player.has_signal("level_up"):
		_player.connect("level_up", Callable(self, "_on_player_level_up"))

	_sync_player_bars()


func set_debug_visible(is_visible: bool) -> void:
	_debug_visible = is_visible
	for node: CanvasItem in _debug_nodes:
		if node != null:
			node.visible = _debug_visible


func _build_ui() -> void:
	var panel_style := _make_panel_style()

	var vitals_panel := PanelContainer.new()
	vitals_panel.position = Vector2(10, 10)
	vitals_panel.custom_minimum_size = Vector2(226, 72)
	vitals_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(vitals_panel)

	var vitals_box := VBoxContainer.new()
	vitals_box.add_theme_constant_override("separation", 4)
	vitals_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	vitals_box.offset_left = 8
	vitals_box.offset_top = 5
	vitals_box.offset_right = -8
	vitals_box.offset_bottom = -6
	vitals_panel.add_child(vitals_box)

	_health_label = Label.new()
	_health_label.text = "HP 200 / 200"
	_health_label.label_settings = _make_label_settings(13, Color(1.0, 0.88, 0.74, 1.0), 3)
	vitals_box.add_child(_health_label)

	_health_bar = ProgressBar.new()
	_health_bar.custom_minimum_size = Vector2(210, 14)
	_health_bar.show_percentage = false
	_health_bar.min_value = 0.0
	_health_bar.max_value = 200.0
	_health_bar.value = 200.0
	_health_bar.add_theme_stylebox_override("background", _make_bar_style(Color(0.16, 0.03, 0.03, 0.92), Color(0.55, 0.12, 0.08, 0.9)))
	_health_bar.add_theme_stylebox_override("fill", _make_bar_style(Color(1.0, 0.18, 0.08, 0.95), Color(1.0, 0.82, 0.18, 0.95)))
	vitals_box.add_child(_health_bar)

	_experience_label = Label.new()
	_experience_label.text = "LV 1  XP 0 / 10"
	_experience_label.label_settings = _make_label_settings(12, Color(0.64, 1.0, 1.0, 1.0), 3)
	vitals_box.add_child(_experience_label)

	_experience_bar = ProgressBar.new()
	_experience_bar.custom_minimum_size = Vector2(210, 10)
	_experience_bar.show_percentage = false
	_experience_bar.min_value = 0.0
	_experience_bar.max_value = 10.0
	_experience_bar.value = 0.0
	_experience_bar.add_theme_stylebox_override("background", _make_bar_style(Color(0.02, 0.08, 0.11, 0.92), Color(0.11, 0.38, 0.45, 0.9)))
	_experience_bar.add_theme_stylebox_override("fill", _make_bar_style(Color(0.14, 0.92, 1.0, 0.95), Color(0.92, 1.0, 0.34, 0.95)))
	vitals_box.add_child(_experience_bar)

	var synergy_panel := PanelContainer.new()
	synergy_panel.position = Vector2(10, 88)
	synergy_panel.custom_minimum_size = Vector2(156, 30)
	synergy_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(synergy_panel)

	var synergy_label := Label.new()
	synergy_label.text = "[*]  SYNERGY ACTIVE"
	synergy_label.label_settings = _make_label_settings(17, Color(0.6, 1.0, 0.95, 1.0), 4)
	synergy_label.modulate = Color(0.6, 1.0, 0.95, 1.0)
	synergy_panel.add_child(synergy_label)

	var inventory := GridContainer.new()
	inventory.columns = 4
	inventory.position = Vector2(10, 124)
	inventory.add_theme_constant_override("h_separation", 2)
	inventory.add_theme_constant_override("v_separation", 2)
	add_child(inventory)

	var icon_texts: Array[String] = ["P", "HOOK", "J", "RED", "ZAP", "ORB", "UP", "BOX", "", "", "CHZ", "GUN"]
	for index: int in icon_texts.size():
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(34, 34)
		slot.add_theme_stylebox_override("panel", panel_style)
		inventory.add_child(slot)

		var slot_label := Label.new()
		slot_label.text = icon_texts[index]
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot_label.label_settings = _make_label_settings(11, Color(0.93, 0.92, 0.78, 1.0), 3)
		slot.add_child(slot_label)

	var rule_label := Label.new()
	rule_label.text = "JONAS'S RULE:\nGAMEPLAY OVER ART"
	rule_label.position = Vector2(172, 64)
	rule_label.label_settings = _make_label_settings(20, Color(0.75, 1.0, 1.0, 1.0), 5)
	add_child(rule_label)
	_debug_nodes.append(rule_label)

	var luca_label := Label.new()
	luca_label.text = "LUCA'S RULE:\nJUCINESS IS EVERYTHING!"
	luca_label.position = Vector2(462, 424)
	luca_label.label_settings = _make_label_settings(21, Color(1.0, 0.92, 0.22, 1.0), 5)
	add_child(luca_label)
	_debug_nodes.append(luca_label)

	_fps_label = Label.new()
	_fps_label.position = Vector2(842, 8)
	_fps_label.label_settings = _make_label_settings(15, Color(0.93, 0.92, 0.78, 1.0), 4)
	add_child(_fps_label)
	_debug_nodes.append(_fps_label)

	_enemy_label = Label.new()
	_enemy_label.position = Vector2(8, 430)
	_enemy_label.label_settings = _make_label_settings(13, Color(0.93, 0.92, 0.78, 1.0), 3)
	add_child(_enemy_label)
	_debug_nodes.append(_enemy_label)


func _sync_player_bars() -> void:
	if _player == null:
		return

	_on_player_health_changed(int(_player.get("current_health")), int(_player.get("max_health")))
	_on_player_experience_changed(int(_player.get("experience")), int(_player.get("experience_to_next_level")), int(_player.get("level")))


func _on_player_health_changed(current: int, maximum: int) -> void:
	var safe_maximum: int = max(1, maximum)
	if _health_bar != null:
		_health_bar.max_value = float(safe_maximum)
		_health_bar.value = float(clampi(current, 0, safe_maximum))
	if _health_label != null:
		_health_label.text = "HP %d / %d" % [clampi(current, 0, safe_maximum), safe_maximum]


func _on_player_experience_changed(current: int, required: int, level: int) -> void:
	var safe_required: int = max(1, required)
	if _experience_bar != null:
		_experience_bar.max_value = float(safe_required)
		_experience_bar.value = float(clampi(current, 0, safe_required))
	if _experience_label != null:
		_experience_label.text = "LV %d  XP %d / %d" % [level, clampi(current, 0, safe_required), safe_required]


func _on_player_level_up(_new_level: int) -> void:
	if _experience_label != null:
		_experience_label.modulate = Color(1.0, 0.95, 0.2, 1.0)
		var tween := create_tween()
		tween.tween_property(_experience_label, "modulate", Color.WHITE, 0.25)


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.07, 0.08, 0.72)
	style.border_color = Color(0.45, 0.9, 0.95, 0.9)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style


func _make_label_settings(font_size: int, font_color: Color, outline_size: int) -> LabelSettings:
	var settings := LabelSettings.new()
	settings.font_color = font_color
	settings.outline_color = Color.BLACK
	settings.outline_size = outline_size
	settings.font_size = font_size
	return settings


func _make_bar_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	return style
