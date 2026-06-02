extends Node

const SCENE_MANAGER = preload("uid://od8k1dbglend")

var game_paused: bool = false
var skip_cutscenes: bool = false
var grid_state: GridState = null
var is_debug: bool = false

var scene_manager: SceneManager

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("full_screen")):
		var mode = DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(mode)
