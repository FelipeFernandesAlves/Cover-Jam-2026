extends Node2D

func _ready() -> void:
	var scenes: Array[PackedScene] = [
		preload("uid://dkwc6dvtx084m"),
		preload("uid://due0bvix3wids")
	]
	Game.scene_manager.scene_sequence = scenes
	Game.scene_manager.load_next()
