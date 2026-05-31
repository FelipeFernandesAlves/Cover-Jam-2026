extends Node

const SCENE_MANAGER = preload("uid://od8k1dbglend")

var game_paused: bool = false
var skip_cutscenes: bool = true
var grid_state: GridState = null
var is_debug: bool = true

var scene_manager: SceneManager

func _ready() -> void:
	pass
	#scene_manager = SCENE_MANAGER.instantiate()
	#add_child(scene_manager)
