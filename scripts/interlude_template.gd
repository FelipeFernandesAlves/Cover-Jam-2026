extends Node2D
@onready var dialog_scene: Control = $DialogScene
@export var dialog_sequence: Array[DialogContent]
signal scene_finished()

func _on_dialog_scene_dialog_scene_finished() -> void:
	scene_finished.emit()
 
