class_name NoiseGen 
extends Node

@export var magnitude: float = 1.0
@export var frequency: float = 2.0
@export var speed: float = 1.0
var active: bool = true
var noise = FastNoiseLite.new()
var time: float
var _value: Vector3 = Vector3.ZERO

func _ready() -> void:
	noise.seed = randi()
	noise.frequency = frequency

func _physics_process(delta: float) -> void:
	if (!active):
		_value = lerp(_value, 0, speed * delta)
		return

	time += delta * speed
	_value = Vector3(
		noise.get_noise_3d(time, 0, 0),
		noise.get_noise_3d(0, time, 0),
		noise.get_noise_3d(0, 0, time),
	) * magnitude

func get_noise_2d() -> Vector2:
	return Vector2(_value.x, _value.y)

func get_noise_1d():
	return _value.x