extends Label3D
class_name DamageText

@export var float_speed: float = 2.4
@export var lifetime: float = 0.7

var _age: float = 0.0
var _side_drift: Vector3 = Vector3.ZERO


func _ready() -> void:
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = false
	fixed_size = true
	font_size = 26
	outline_size = 6
	outline_modulate = Color.BLACK
	modulate = Color(1.0, 0.84, 0.18, 1.0)
	_side_drift = Vector3(randf_range(-0.25, 0.25), 0.0, randf_range(-0.25, 0.25))


func _process(delta: float) -> void:
	_age += delta
	position += (Vector3.UP * float_speed + _side_drift) * delta

	var life_ratio: float = clamp(_age / lifetime, 0.0, 1.0)
	modulate.a = 1.0 - life_ratio
	scale = Vector3.ONE * lerp(1.0, 1.12, life_ratio)

	if _age >= lifetime:
		queue_free()


func configure(display_text: String, start_position: Vector3, color: Color) -> void:
	text = display_text
	global_position = start_position
	modulate = color
