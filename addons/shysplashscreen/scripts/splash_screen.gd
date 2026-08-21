class_name SplashScreen extends Control

@export var next_scene: PackedScene
@export var animation_player: AnimationPlayer
@export var texture_rect: TextureRect

var time: float
var amp: float = 5
var spd: float = 1.8

signal splash_screen_ended()

func _ready() -> void:
	animation_player.play("fade")
	splash_screen_ended.connect(func():
		get_tree().change_scene_to_packed(next_scene)
		)

func _process(delta: float) -> void:
	time += delta * spd
	texture_rect.position.y = sin(time) * amp
	if (Input.is_action_just_pressed("dialog_interact")):
		animation_player.stop()
		on_end()

func on_end():
	splash_screen_ended.emit()
