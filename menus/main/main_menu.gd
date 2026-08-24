extends Node2D

@export var main_scene: PackedScene
@export var characters_parent: Node2D

@export var start_button: Button
@export var exit_button: Button

@export var transition_rect: ColorRect
@export var game_start_sound: AudioStreamPlayer

var start_pressed: bool = false

func _ready() -> void:
	Game.keys.set("tutorial_viewed", false)

func _on_start_pressed() -> void:
	if (start_pressed):
		return
	
	start_button.disabled = true
	exit_button.disabled = true

	start_pressed = true
	game_start_sound.reparent(get_parent())
	game_start_sound.play()
	game_start_sound.finished.connect(game_start_sound.queue_free)

	var tween = create_tween()
	Input.start_joy_vibration(0, 0.2, 0.4, 0.8)
	tween.tween_property(characters_parent, "global_position:x", 760, 2.0)
	tween.set_parallel()
	tween.tween_property(transition_rect, "modulate:a", 1.0, 2.0)
	tween.finished.connect(func ():
		get_tree().change_scene_to_packed(main_scene)
		)

func _on_exit_pressed() -> void:
	if (start_pressed):
		return

	get_tree().quit()
