extends HBoxContainer

@export var keyboard_rect: TextureRect
@export var gamepad_rect: TextureRect
var last_is_gamepad_mode: bool

func _ready() -> void:
	_update_gamepad_mode()

func _physics_process(_delta: float) -> void:
	if (last_is_gamepad_mode != Game.is_gamepad_mode):
		last_is_gamepad_mode = Game.is_gamepad_mode
		_update_gamepad_mode()

func _update_gamepad_mode():
	if (!keyboard_rect || !gamepad_rect):
		return
		
	if (Game.is_gamepad_mode):
		keyboard_rect.hide()
		gamepad_rect.show()
	else:
		keyboard_rect.show()
		gamepad_rect.hide()
	
