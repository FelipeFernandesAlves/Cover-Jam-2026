extends Node2D

@export var size_scale: float = 1.0
@export var light_parent: Node2D
@export var noise: NoiseGen
var lights: Array[Node]
var scales: Array[float]
var active: bool = true

func _ready() -> void:
	if (light_parent):
		lights = light_parent.get_children()
	
	for light in lights:
		light.texture_scale *= size_scale
		scales.append(light.texture_scale)

	noise.time += randf_range(0, 10)

func _physics_process(_delta: float) -> void:
	if (!noise || !light_parent):
		return

	for i in lights.size():
		var light = lights[i]
		light.texture_scale = scales[i] + noise.get_noise_1d()

func disable():
	if (!active):
		return

	active = false
	noise.active = false
	for light in lights:
		var tween = create_tween()
		tween.tween_property(light, "texture_scale", 0.0, 1.6)
