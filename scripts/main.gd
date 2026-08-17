extends Node2D

@export var pause_menu: PauseMenu
@export var scene_manager: SceneManager
@export var music: AudioStreamPlayer
var music_volume: float
var music_tween: Tween
var paused: bool

signal on_pause()

func _ready() -> void:
	get_tree().paused = false
	pause_menu.hide()
	music_volume = music.volume_db

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("pause")):
		get_tree().paused = !get_tree().paused 
		pause_menu.change_visibility(get_tree().paused)

	if (get_tree().paused != paused):
		paused = get_tree().paused
		on_pause.emit()

func _on_on_pause() -> void:
	if (music_tween):
		music_tween.kill()
		music_tween = null
	
	music_tween = create_tween()

	if (paused):
		music_tween.tween_property(music, "volume_db", music_volume - 10, 1.25)
	else:
		music_tween.tween_property(music, "volume_db", music_volume, 1.25)
