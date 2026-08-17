extends MenuPage

@export var music_slider: HSlider
@export var sound_slider: HSlider
@export var back_button: Button

var options: Array[Control]
var current_focus_index: int = 0

func _ready() -> void:
	options = [
		music_slider,
		sound_slider,
		back_button
	]

func _input(event: InputEvent) -> void:
	if (!is_inside_tree()):
		return

	var option: Control = options[current_focus_index]

	if (option is Slider):
		if (event.is_action_pressed("left_ui")):
			options[current_focus_index].value -= option.step
		elif (event.is_action_pressed("right_ui")):
			options[current_focus_index].value += option.step
	elif (option is Button):
		if (event.is_action_pressed("dialog_interact")):
			options[current_focus_index].pressed.emit()

	if (event.is_action_pressed("up_ui")):
		current_focus_index -= 1
	elif (event.is_action_pressed("down_ui")):
		current_focus_index += 1

	_update_focus()

func _update_focus():
	if (options.size() > 0):
		current_focus_index = current_focus_index % options.size()

		if (is_inside_tree()):
			options[current_focus_index].grab_focus.call_deferred()

func _on_page_entered() -> void:
	music_slider.value = Configuration.music_volume
	sound_slider.value = Configuration.sfx_volume

func _on_music_slider_value_changed(value: float) -> void:
	Configuration.music_volume = value

func _on_sound_slider_value_changed(value: float) -> void:
	Configuration.sfx_volume = value

func _on_back_button_pressed() -> void:
	go_to_last_page.emit()
