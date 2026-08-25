class_name ButtonBox
extends VBoxContainer

@export var button_icon: Texture2D
@export var menu_audio: AudioStreamPlayer
@export var select_audio: AudioStreamPlayer
var current_focus_index: int = 0
var buttons: Array[Button] = []

func _ready() -> void:
	for button in get_children():
		if (button is Button):
			buttons.append(button)
			button.focus_entered.connect(_on_button_focus_entered.bind(button))
			button.focus_exited.connect(_on_button_focus_exited.bind(button))
			button.mouse_entered.connect(_on_mouse_entered.bind(button))
			button.pressed.connect(_on_button_pressed)
			button.focus_mode = Control.FOCUS_ALL

	if (buttons.size() > 0):
		buttons[0].grab_focus()

func _enter_tree() -> void:
	hide()
	_update_focus()
	show()
	
func _input(event: InputEvent) -> void:
	if (!is_inside_tree()):
		return

	if (event.is_action_pressed("dialog_interact")):
		buttons[current_focus_index].pressed.emit()

	if (event.is_action_pressed("up_ui")):
		current_focus_index -= 1
	elif (event.is_action_pressed("down_ui")):
		current_focus_index += 1

	_update_focus()

func _update_focus():
	if (!is_inside_tree()):
		return

	if (buttons.size() > 0):
		current_focus_index = current_focus_index % buttons.size()

		if (is_inside_tree()):
			buttons[current_focus_index].grab_focus.call_deferred()

func _on_button_focus_entered(button: Button):
	if (button_icon):
		button.icon = button_icon
	
	if (menu_audio && visible):
		menu_audio.play()

func _on_button_focus_exited(button: Button):
	if (button_icon):
		button.icon = null

func _on_mouse_entered(button: Button):
	if (!is_inside_tree()):
		return

	button.grab_focus()
	current_focus_index = buttons.find(button)
	_update_focus()

func _on_button_pressed():
	if (select_audio && visible):
		select_audio.play()

func reset_focus():
	hide()
	current_focus_index = 0
	_update_focus()
	show()
