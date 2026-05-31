extends Node

signal dialog_scene_finished()

@export var dialog_sequence : Array[DialogContent] = []
const DIALOG_UI = preload("res://entities/DialogUI.tscn")

var current_dialog_index : int = 0
var current_dialog_scene = null

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

func load_dialog(json_path: String, dialog_name: String):
	if FileAccess.file_exists(json_path):
		var data_string = FileAccess.get_file_as_string(json_path)
		var parsed_data: Dictionary = JSON.parse_string(data_string)
		var dialog: Array = parsed_data.get(dialog_name)
		
		for c: Dictionary in dialog:
			var char_path := str("res://characters/", c.get("character")[0], ".tres")
			if (!ResourceLoader.exists(char_path)):
				print("Character not found: ", char_path)
				return
				
			var sheet: DialogCharacterSheet = ResourceLoader.load(char_path)
			var char_image: Texture2D = sheet.get(c.get("character")[1])
			var dir: DialogContent.ImageDirection = DialogContent.ImageDirection.get(c.get("character")[2])
			
			var content = DialogContent.new(
				c.get("character")[0],
				c.get("text"),
				char_image,
				dir
			)
			
			dialog_sequence.append(content)
		show_dialog()
	
func _on_single_dialog_ended(_dialog):
	go_to_next_dialog()
