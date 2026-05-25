extends Node
class_name UpgradeDirector

const UPGRADE_CHEDDAR_BARRAGE: StringName = &"cheddar_barrage"
const UPGRADE_QUICK_PAWS: StringName = &"quick_paws"
const UPGRADE_EMERGENCY_SNACK: StringName = &"emergency_snack"

@export var player_path: NodePath
@export var combat_director_path: NodePath
@export var ui_path: NodePath
@export var quick_paws_multiplier: float = 0.85
@export var minimum_fire_interval: float = 0.06
@export var emergency_snack_max_health_bonus: int = 40
@export var emergency_snack_heal_amount: int = 40

var _player: Node
var _combat_director: Node
var _ui: Node


func _ready() -> void:
	_player = get_node_or_null(player_path)
	_combat_director = get_node_or_null(combat_director_path)
	_ui = get_node_or_null(ui_path)

	if _player == null:
		push_error("UpgradeDirector needs a valid player_path.")
		return
	if _combat_director == null:
		push_error("UpgradeDirector needs a valid combat_director_path.")
		return
	if _ui == null:
		push_error("UpgradeDirector needs a valid ui_path.")
		return

	if _player.has_signal("level_up"):
		_player.connect("level_up", Callable(self, "_on_player_level_up"))
	if _ui.has_signal("upgrade_selected"):
		_ui.connect("upgrade_selected", Callable(self, "_on_upgrade_selected"))


func _on_player_level_up(new_level: int) -> void:
	if _ui.has_method("show_upgrade_choices"):
		_ui.call("show_upgrade_choices", new_level)


func _on_upgrade_selected(upgrade_id: StringName) -> void:
	match upgrade_id:
		UPGRADE_CHEDDAR_BARRAGE:
			_apply_cheddar_barrage()
		UPGRADE_QUICK_PAWS:
			_apply_quick_paws()
		UPGRADE_EMERGENCY_SNACK:
			_apply_emergency_snack()
		_:
			push_warning("Unknown upgrade selected: %s" % String(upgrade_id))

	if _ui.has_method("hide_upgrade_choices"):
		_ui.call("hide_upgrade_choices")


func _apply_cheddar_barrage() -> void:
	if _combat_director.has_method("increase_burst_count"):
		_combat_director.call("increase_burst_count", 1)


func _apply_quick_paws() -> void:
	if _combat_director.has_method("multiply_fire_interval"):
		_combat_director.call("multiply_fire_interval", quick_paws_multiplier, minimum_fire_interval)


func _apply_emergency_snack() -> void:
	if _player.has_method("increase_max_health"):
		_player.call("increase_max_health", emergency_snack_max_health_bonus, emergency_snack_heal_amount)
