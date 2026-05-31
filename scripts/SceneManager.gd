class_name SceneManager
extends Node

@export var scene_sequence: Array[PackedScene]
@export var fade_duration: float = 1.0
@export var tempo_tela_preta: float = 1.0

@onready var scene_container: Node = $SceneContainer
@onready var fade_rect: ColorRect = $TransitionLayer/FadeRect

var current_index: int = 0
var active_scene: Node = null

func _ready() -> void:
	# Start with the screen completely black
	fade_rect.color.a = 0.0
	
	if scene_sequence.size() > 0:
		load_scene(current_index)
	else:
		push_warning("Scene Manager has no scenes in its array!")

func load_next():
	load_scene(current_index + 1)

func load_scene(index: int) -> void:
	if index >= scene_sequence.size():
		print("You reached the end of the sequence!")
		return
		
	# 1. Instantiate the next scene
	active_scene = scene_sequence[index].instantiate()
	
	# 2. Connect the signal. 
	# We check if it exists so the game doesn't crash if you forget to add it to a scene.
	if active_scene.has_signal("scene_finished"):
		active_scene.scene_finished.connect(_on_current_scene_finished)
	else:
		push_warning("The loaded scene does not have a 'scene_finished' signal!")
		
	# 3. Add it to the container
	scene_container.add_child(active_scene)
	
	# 4. Fade In (Animate alpha from 1.0 to 0.0 to reveal the scene)
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, fade_duration)

func _on_current_scene_finished() -> void:
	var tween = create_tween()
	
	# 1. Fade Out: Anima a transparência (alpha) até 1.0 para esconder a cena
	tween.tween_property(fade_rect, "color:a", 1.0, fade_duration)
	
	# 2. O Segredo: Adiciona um tempo de espera (intervalo) na fila do Tween!
	tween.tween_interval(tempo_tela_preta)
	
	# 3. Quando o intervalo acabar, ele troca as cenas
	# (E a nova cena ao carregar já vai disparar o Fade In automaticamente)
	tween.tween_callback(swap_to_next_scene)

func swap_to_next_scene() -> void:
	# Safely delete the old scene
	if active_scene:
		active_scene.queue_free()
		
	# Increment the index and load the next one
	current_index += 1
	load_scene(current_index)
