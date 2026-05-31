extends Node

signal dialog_scene_finished()

@export var dialog_sequence : Array[DialogContent] = []
const DIALOG_UI = preload("res://entities/DialogUI.tscn")

var current_dialog_index : int = 0
var current_dialog_scene = null

func _ready() -> void:
	show_dialog() 

func show_dialog():
	if current_dialog_index >= dialog_sequence.size():
		return
		
	var new_dialog = DIALOG_UI.instantiate()
	new_dialog.content = dialog_sequence[current_dialog_index]
	add_child(new_dialog)
	
	if current_dialog_scene:
		current_dialog_scene.queue_free()
	
	current_dialog_scene = new_dialog
	current_dialog_scene.dialog_finished.connect(_on_single_dialog_ended.bind(new_dialog))
	
func go_to_next_dialog():
	current_dialog_index += 1
	if current_dialog_index >= dialog_sequence.size():
		if current_dialog_scene:
			current_dialog_scene.queue_free()
			
		dialog_scene_finished.emit()
		return
	
	show_dialog()

func _on_single_dialog_ended(_dialog):
	go_to_next_dialog()
