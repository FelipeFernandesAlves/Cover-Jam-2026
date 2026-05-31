class_name LevelManager
extends Node

@onready var animation: AnimationPlayer = $Animation
@onready var label: Label = $CanvasLayer/Transition/Label
@onready var start_level_timer: Timer = $StartLevelTimer
@onready var level_time: Label = $CanvasLayer/LevelUI/MarginContainer/VFlowContainer/VBoxContainer/LevelTime
@onready var level_title: Label = $CanvasLayer/LevelUI/MarginContainer/VFlowContainer/VBoxContainer/LevelTitle
@onready var level_moves: Label = $CanvasLayer/LevelUI/MarginContainer/VFlowContainer/LevelMoves

@onready var grid_state: GridState = $"../GridState"

@export var title: String
@export var max_moves: int = 4
var current_moves: int = 0
var current_time: float

signal level_won()
signal level_restart()

func _ready() -> void:
	label.text = title
	level_title.text = title
	level_time.text = "0:00.0"
	start_level_timer.timeout.connect(_on_start_level_timer)
	level_restart.connect(on_restart_level)
	level_won.connect(on_level_won)
	grid_state.entity_moved.connect(_on_entity_moved)
	if (!Game.skip_cutscenes):
		animation.play("level_intro")
		Game.game_paused = true

func _exit_tree() -> void:
	start_level_timer.timeout.disconnect(_on_start_level_timer)
	level_restart.disconnect(on_restart_level)
	grid_state.entity_moved.disconnect(_on_entity_moved)

func _process(delta: float) -> void:
	if (Game.game_paused): return
	level_moves.text = str(current_moves, "/", max_moves)
	
	if (Input.is_action_just_pressed("restart_level")):
		level_restart.emit()
	
	if (current_moves > max_moves):
		level_restart.emit()
	
	if (Game.is_debug && Input.is_action_just_pressed("skip_level")):
		level_won.emit()
	
	# Level Timer
	current_time += delta
	var minutes := current_time / 60.0
	var seconds := int(current_time) % 60
	var miliseconds := int((current_time - int(current_time)) * 10)
	level_time.text = "%02d:%02d.%01d" % [minutes, seconds, miliseconds]

func _on_entity_moved(entity: GridEntityData, _from_pos: Vector2i, _to_pos: Vector2i):
	if (entity.type == GridState.CellType.PLAYER):
		current_moves += 1

func _on_intro_finished():
	start_level_timer.start()

func _on_start_level_timer():
	Game.game_paused = false

func on_restart_level():
	Game.game_paused = true
	var player: Player = get_tree().get_first_node_in_group("player")
	player.die()
	await get_tree().create_timer(1.2).timeout
	animation.play("level_restart")

func on_level_won():
	Game.game_paused = true

func _restart_level():
	get_tree().reload_current_scene()
	Game.skip_cutscenes = true
	Game.game_paused = false
