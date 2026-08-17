extends Node

const SCENE_MANAGER = preload("uid://od8k1dbglend")

var game_paused: bool = false
var skip_cutscenes: bool = false
var grid_state: GridState = null
var is_debug: bool = false

var scene_manager: SceneManager
var is_gamepad_mode: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	randomize()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up") or \
		event.is_action_pressed("ui_down") or \
		event.is_action_pressed("ui_left") or \
		event.is_action_pressed("ui_right") or \
		event.is_action_pressed("ui_focus_next") or \
		event.is_action_pressed("ui_focus_prev"):
		get_viewport().set_input_as_handled()

	if (event.is_action_pressed("full_screen")):
		var mode = DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(mode)

	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	is_gamepad_mode = false

	if (event is InputEventJoypadButton || event is InputEventJoypadMotion):
		is_gamepad_mode = true
		return
	
	if (event is InputEventMouse):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	