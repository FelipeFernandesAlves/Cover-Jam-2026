extends "res://scripts/interlude_template.gd"

@export var color_rect: ColorRect

func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, 2.0)

