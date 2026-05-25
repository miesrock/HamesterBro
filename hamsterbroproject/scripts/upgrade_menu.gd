extends Control
class_name UpgradeMenu

signal upgrade_selected(upgrade_id: StringName)

const UPGRADE_CHOICES: Array[Dictionary] = [
	{
		"id": &"cheddar_barrage",
		"title": "CHEDDAR BARRAGE",
		"body": "+1 rainbow bullet per burst",
	},
	{
		"id": &"quick_paws",
		"title": "QUICK PAWS",
		"body": "Fire 15% faster",
	},
	{
		"id": &"emergency_snack",
		"title": "EMERGENCY SNACK",
		"body": "+40 max HP and heal 40",
	},
]

var _title_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_fit_to_viewport()
	get_viewport().size_changed.connect(_fit_to_viewport)
	visible = false
	_build_ui()


func show_choices(level: int) -> void:
	_title_label.text = "LEVEL %d UPGRADE" % level
	visible = true


func hide_choices() -> void:
	visible = false


func is_open() -> bool:
	return visible


func _fit_to_viewport() -> void:
	position = Vector2.ZERO
	size = get_viewport_rect().size


func _build_ui() -> void:
	var blocker := ColorRect.new()
	blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	blocker.color = Color(0.0, 0.0, 0.0, 0.52)
	add_child(blocker)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 260)
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	center.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	_title_label = Label.new()
	_title_label.text = "LEVEL UP"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.label_settings = _make_label_settings(26, Color(1.0, 0.94, 0.22, 1.0), 5)
	box.add_child(_title_label)

	var subtitle := Label.new()
	subtitle.text = "CHOOSE ONE"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.label_settings = _make_label_settings(14, Color(0.65, 1.0, 1.0, 1.0), 3)
	box.add_child(subtitle)

	var choices := HBoxContainer.new()
	choices.add_theme_constant_override("separation", 10)
	box.add_child(choices)

	for choice: Dictionary in UPGRADE_CHOICES:
		choices.add_child(_make_choice_button(choice))


func _make_choice_button(choice: Dictionary) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(190, 122)
	button.text = "%s\n\n%s" % [String(choice["title"]), String(choice["body"])]
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.05, 0.11, 0.12, 0.96), Color(0.2, 0.95, 1.0, 0.9)))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.13, 0.2, 0.16, 0.98), Color(1.0, 0.92, 0.2, 1.0)))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.2, 0.12, 0.05, 0.98), Color(1.0, 0.45, 0.12, 1.0)))
	button.pressed.connect(func() -> void:
		upgrade_selected.emit(choice["id"])
	)
	return button


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.05, 0.06, 0.94)
	style.border_color = Color(0.95, 0.9, 0.18, 1.0)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.content_margin_left = 18
	style.content_margin_top = 16
	style.content_margin_right = 18
	style.content_margin_bottom = 16
	return style


func _make_button_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
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
