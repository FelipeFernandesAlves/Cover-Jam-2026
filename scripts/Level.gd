extends Node2D

@onready var level_manager: LevelManager = $LevelManager
signal scene_finished()

func _ready() -> void:
	level_manager.level_won.connect(func():
		scene_finished.emit()
		)
