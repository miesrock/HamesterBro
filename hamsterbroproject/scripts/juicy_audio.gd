extends Node
class_name JuicyAudio

@export_range(-40.0, 6.0, 0.5) var master_volume_db: float = -8.0
@export_range(0.0, 1.0, 0.05) var shoot_volume: float = 0.28
@export_range(0.0, 1.0, 0.05) var hit_volume: float = 0.38
@export_range(0.0, 1.0, 0.05) var crit_volume: float = 0.55
@export_range(0.0, 1.0, 0.05) var voice_volume: float = 0.42
@export var pool_size: int = 18
@export var shoot_cooldown: float = 0.045
@export var voice_cooldown: float = 0.65

var _players: Array[AudioStreamPlayer] = []
var _rng := RandomNumberGenerator.new()
var _shoot_stream: AudioStreamWAV
var _hit_streams: Array[AudioStreamWAV] = []
var _crit_stream: AudioStreamWAV
var _voice_streams: Array[AudioStreamWAV] = []
var _shoot_timer: float = 0.0
var _voice_timer: float = 0.0
var _next_player_index: int = 0

const MIX_RATE: int = 44100
const TAU_FLOAT: float = TAU


func _ready() -> void:
	_rng.randomize()
	_build_streams()
	_build_player_pool()


func _process(delta: float) -> void:
	_shoot_timer = maxf(0.0, _shoot_timer - delta)
	_voice_timer = maxf(0.0, _voice_timer - delta)


func play_shoot() -> void:
	if _shoot_timer > 0.0:
		return

	_shoot_timer = shoot_cooldown
	_play_stream(_shoot_stream, shoot_volume, _rng.randf_range(0.92, 1.12))


func play_hit() -> void:
	if _hit_streams.is_empty():
		return

	var stream: AudioStreamWAV = _hit_streams[_rng.randi_range(0, _hit_streams.size() - 1)]
	_play_stream(stream, hit_volume, _rng.randf_range(0.88, 1.18))


func play_crit() -> void:
	_play_stream(_crit_stream, crit_volume, _rng.randf_range(0.96, 1.08))
	_play_voice(false)


func play_big_callout() -> void:
	_play_voice(true)


func _play_voice(force: bool) -> void:
	if not force and _voice_timer > 0.0:
		return
	if _voice_streams.is_empty():
		return

	_voice_timer = voice_cooldown
	var stream: AudioStreamWAV = _voice_streams[_rng.randi_range(0, _voice_streams.size() - 1)]
	_play_stream(stream, voice_volume, _rng.randf_range(0.92, 1.06))


func _build_player_pool() -> void:
	for _index: int in pool_size:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		player.volume_db = master_volume_db
		add_child(player)
		_players.append(player)


func _play_stream(stream: AudioStreamWAV, linear_volume: float, pitch: float) -> void:
	if stream == null or _players.is_empty():
		return

	var player := _players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _players.size()
	player.stop()
	player.stream = stream
	player.pitch_scale = pitch
	player.volume_db = master_volume_db + linear_to_db(maxf(0.001, linear_volume))
	player.play()


func _build_streams() -> void:
	_shoot_stream = _make_stream(0.105, _sample_shoot)
	_hit_streams = [
		_make_stream(0.075, _sample_hit_pop),
		_make_stream(0.09, _sample_hit_snap),
	]
	_crit_stream = _make_stream(0.22, _sample_crit)
	_voice_streams = [
		_make_stream(0.26, _sample_voice_ham),
		_make_stream(0.34, _sample_voice_juice),
	]


func _make_stream(duration: float, sampler: Callable) -> AudioStreamWAV:
	var frames: int = int(duration * float(MIX_RATE))
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)

	for index: int in frames:
		var t: float = float(index) / float(MIX_RATE)
		var sample: float = clampf(float(sampler.call(t, duration)), -1.0, 1.0)
		_write_i16(bytes, index * 2, int(sample * 32767.0))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = bytes
	return stream


func _write_i16(bytes: PackedByteArray, offset: int, value: int) -> void:
	var clamped: int = clampi(value, -32768, 32767)
	if clamped < 0:
		clamped += 65536
	bytes[offset] = clamped & 0xff
	bytes[offset + 1] = (clamped >> 8) & 0xff


func _env(t: float, duration: float, attack: float = 0.006, release_power: float = 2.0) -> float:
	var attack_part: float = clampf(t / attack, 0.0, 1.0)
	var release_part: float = pow(clampf(1.0 - (t / duration), 0.0, 1.0), release_power)
	return attack_part * release_part


func _sample_shoot(t: float, duration: float) -> float:
	var p: float = t / duration
	var freq: float = lerpf(980.0, 290.0, p)
	var wobble: float = sin(TAU_FLOAT * 34.0 * t) * 0.18
	var tone: float = sin(TAU_FLOAT * freq * t + wobble)
	var sparkle: float = sin(TAU_FLOAT * freq * 2.05 * t) * 0.22
	return (tone + sparkle) * _env(t, duration, 0.004, 2.5) * 0.72


func _sample_hit_pop(t: float, duration: float) -> float:
	var p: float = t / duration
	var thump: float = sin(TAU_FLOAT * lerpf(165.0, 80.0, p) * t)
	var click: float = sin(TAU_FLOAT * 2400.0 * t) * pow(maxf(0.0, 1.0 - p), 9.0)
	var grit: float = _noise(t, 91.0) * pow(maxf(0.0, 1.0 - p), 6.0)
	return (thump * 0.55 + click * 0.25 + grit * 0.2) * _env(t, duration, 0.003, 1.8)


func _sample_hit_snap(t: float, duration: float) -> float:
	var p: float = t / duration
	var body: float = sin(TAU_FLOAT * lerpf(240.0, 115.0, p) * t)
	var snap: float = signf(sin(TAU_FLOAT * 1700.0 * t)) * pow(maxf(0.0, 1.0 - p), 7.0)
	return (body * 0.5 + snap * 0.18) * _env(t, duration, 0.002, 2.2)


func _sample_crit(t: float, duration: float) -> float:
	var p: float = t / duration
	var step: int = mini(3, int(p * 4.0))
	var freq: float = [520.0, 690.0, 880.0, 1180.0][step]
	var tone: float = sin(TAU_FLOAT * freq * t)
	var bright: float = sin(TAU_FLOAT * freq * 2.0 * t) * 0.18
	var bell: float = sin(TAU_FLOAT * 1760.0 * t) * pow(maxf(0.0, 1.0 - p), 2.8) * 0.18
	return (tone + bright + bell) * _env(t, duration, 0.004, 1.4) * 0.72


func _sample_voice_ham(t: float, duration: float) -> float:
	var p: float = t / duration
	var vowel: float = _formant_voice(t, lerpf(185.0, 135.0, p), 720.0, 1250.0)
	var bite: float = sin(TAU_FLOAT * 95.0 * t) * 0.12
	return (vowel + bite) * _env(t, duration, 0.018, 1.3) * 0.55


func _sample_voice_juice(t: float, duration: float) -> float:
	var p: float = t / duration
	var pitch: float = 155.0 + sin(p * PI) * 75.0
	var vowel: float = _formant_voice(t, pitch, 520.0 + p * 260.0, 1600.0)
	var fizz: float = _noise(t, 230.0) * pow(sin(p * PI), 2.0) * 0.16
	return (vowel + fizz) * _env(t, duration, 0.02, 1.2) * 0.52


func _formant_voice(t: float, pitch: float, formant_a: float, formant_b: float) -> float:
	var carrier: float = signf(sin(TAU_FLOAT * pitch * t)) * 0.45
	var mouth_a: float = sin(TAU_FLOAT * formant_a * t) * 0.25
	var mouth_b: float = sin(TAU_FLOAT * formant_b * t) * 0.13
	return carrier + mouth_a + mouth_b


func _noise(t: float, rate: float) -> float:
	return sin(TAU_FLOAT * rate * t * 12.9898 + sin(t * 78.233) * 437.5453)
