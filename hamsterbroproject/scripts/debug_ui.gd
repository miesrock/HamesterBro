extends CanvasLayer
class_name DebugUI

@export var enemy_spawner_path: NodePath

var _fps_label: Label
var _enemy_label: Label
var _spawner: Node


func _ready() -> void:
	_spawner = get_node_or_null(enemy_spawner_path)
	_build_ui()


func _process(_delta: float) -> void:
	if _fps_label != null:
		_fps_label.text = "FPS: %d\nDEBUG VIEW: ACTIVE\n\"JUICE\" SETTING: MAX" % Engine.get_frames_per_second()
	if _enemy_label != null:
		var target_count: int = 120
		if _spawner != null:
			target_count = int(_spawner.get("target_count"))
		_enemy_label.text = "DEBUG UI\nFPS: %d\nDEBUG VIEW: ACTIVE\n\"JUICE\" SETTING: VISUAL OVERLOAD\nENEMY COUNT: %d / %d" % [
			Engine.get_frames_per_second(),
			get_tree().get_nodes_in_group("enemies").size(),
			target_count,
		]


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.04, 0.07, 0.08, 0.72)
	panel_style.border_color = Color(0.45, 0.9, 0.95, 0.9)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4

	var health_panel := PanelContainer.new()
	health_panel.position = Vector2(10, 10)
	health_panel.custom_minimum_size = Vector2(146, 32)
	health_panel.add_theme_stylebox_override("panel", panel_style)
	root.add_child(health_panel)

	var health_label := Label.new()
	health_label.text = "[+]  HEALTH / 200"
	health_label.label_settings = _make_label_settings(18, Color(0.93, 0.92, 0.78, 1.0), 4)
	health_panel.add_child(health_label)

	var synergy_panel := PanelContainer.new()
	synergy_panel.position = Vector2(10, 48)
	synergy_panel.custom_minimum_size = Vector2(156, 30)
	synergy_panel.add_theme_stylebox_override("panel", panel_style)
	root.add_child(synergy_panel)

	var synergy_label := Label.new()
	synergy_label.text = "[*]  SYNERGY ACTIVE"
	synergy_label.label_settings = _make_label_settings(17, Color(0.6, 1.0, 0.95, 1.0), 4)
	synergy_label.modulate = Color(0.6, 1.0, 0.95, 1.0)
	synergy_panel.add_child(synergy_label)

	var inventory := GridContainer.new()
	inventory.columns = 4
	inventory.position = Vector2(10, 84)
	inventory.add_theme_constant_override("h_separation", 2)
	inventory.add_theme_constant_override("v_separation", 2)
	root.add_child(inventory)

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
	root.add_child(rule_label)

	var luca_label := Label.new()
	luca_label.text = "LUCA'S RULE:\nJUCINESS IS EVERYTHING!"
	luca_label.position = Vector2(462, 424)
	luca_label.label_settings = _make_label_settings(21, Color(1.0, 0.92, 0.22, 1.0), 5)
	root.add_child(luca_label)

	_fps_label = Label.new()
	_fps_label.position = Vector2(842, 8)
	_fps_label.label_settings = _make_label_settings(15, Color(0.93, 0.92, 0.78, 1.0), 4)
	root.add_child(_fps_label)

	_enemy_label = Label.new()
	_enemy_label.position = Vector2(8, 430)
	_enemy_label.label_settings = _make_label_settings(13, Color(0.93, 0.92, 0.78, 1.0), 3)
	root.add_child(_enemy_label)


func _make_label_settings(font_size: int, font_color: Color, outline_size: int) -> LabelSettings:
	var settings := LabelSettings.new()
	settings.font_color = font_color
	settings.outline_color = Color.BLACK
	settings.outline_size = outline_size
	settings.font_size = font_size
	return settings
