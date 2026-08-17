class_name Sine
extends Node

@export var active: bool = true
@export var magnitude: float = 1.0
@export var period: float = 1.0
var _time: float
var _value: float

func _process(delta: float) -> void:
	if (!active):
		_value = move_toward(_value, 0, 0.25)
		return

	_time += delta
	_value = sin(_time * (1/period)) * magnitude

func get_sine() -> float:
	return _value