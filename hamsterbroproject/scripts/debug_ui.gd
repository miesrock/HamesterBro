extends CanvasLayer
class_name DebugUI

signal upgrade_selected(upgrade_id: StringName)

const HUDScript := preload("res://scripts/ui_hud.gd")
const UpgradeMenuScript := preload("res://scripts/upgrade_menu.gd")
const PauseMenuScript := preload("res://scripts/pause_menu.gd")
const SettingsMenuScript := preload("res://scripts/settings_menu.gd")

@export var enemy_spawner_path: NodePath
@export var player_path: NodePath

var _hud: Node
var _upgrade_menu: Node
var _pause_menu: Node
var _settings_menu: Node
var _player: Node
var _spawner: Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_spawner = get_node_or_null(enemy_spawner_path)
	_player = _resolve_player()
	_build_ui()
	_wire_ui()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not _is_upgrade_open():
		_toggle_pause_menu()


func show_upgrade_choices(level: int) -> void:
	_close_pause_views()
	get_tree().paused = true
	_upgrade_menu.call("show_choices", level)


func hide_upgrade_choices() -> void:
	_upgrade_menu.call("hide_choices")
	get_tree().paused = false


func is_upgrade_open() -> bool:
	return _is_upgrade_open()


func _build_ui() -> void:
	_hud = HUDScript.new()
	add_child(_hud)
	_hud.call("set_spawner", _spawner)
	_hud.call("set_player", _player)

	_upgrade_menu = UpgradeMenuScript.new()
	add_child(_upgrade_menu)

	_pause_menu = PauseMenuScript.new()
	add_child(_pause_menu)

	_settings_menu = SettingsMenuScript.new()
	add_child(_settings_menu)


func _wire_ui() -> void:
	_upgrade_menu.upgrade_selected.connect(func(upgrade_id: StringName) -> void:
		upgrade_selected.emit(upgrade_id)
	)
	_pause_menu.resume_requested.connect(_resume_from_pause)
	_pause_menu.settings_requested.connect(_open_settings_menu)
	_settings_menu.back_requested.connect(_close_settings_menu)
	_settings_menu.debug_visibility_changed.connect(func(is_visible: bool) -> void:
		_hud.call("set_debug_visible", is_visible)
	)


func _resolve_player() -> Node:
	if not player_path.is_empty:
		var path_player := get_node_or_null(player_path)
		if path_player != null:
			return path_player

	return get_tree().get_first_node_in_group("player")


func _toggle_pause_menu() -> void:
	if bool(_settings_menu.call("is_open")):
		_close_settings_menu()
		return

	if bool(_pause_menu.call("is_open")):
		_resume_from_pause()
	else:
		get_tree().paused = true
		_pause_menu.call("show_menu")


func _resume_from_pause() -> void:
	_close_pause_views()
	get_tree().paused = false


func _open_settings_menu() -> void:
	_pause_menu.call("hide_menu")
	_settings_menu.call("show_menu")


func _close_settings_menu() -> void:
	_settings_menu.call("hide_menu")
	_pause_menu.call("show_menu")


func _close_pause_views() -> void:
	_pause_menu.call("hide_menu")
	_settings_menu.call("hide_menu")


func _is_upgrade_open() -> bool:
	return _upgrade_menu != null and bool(_upgrade_menu.call("is_open"))
