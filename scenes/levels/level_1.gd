extends "res://scripts/Level.gd"

@export var tutorial: Tutorial

func _ready() -> void:
	super()
	if (tutorial):
		tutorial.visible = false
		
		if (!Game.keys.get("tutorial_viewed")):
			await level_manager.level_started
			tutorial.show_tutorial()
			Game.keys.set("tutorial_viewed", true)
