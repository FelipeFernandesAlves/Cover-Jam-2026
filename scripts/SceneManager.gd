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
	# Começa com a tela completamente preta
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
		
	# 1. Instancia a próxima cena
	active_scene = scene_sequence[index].instantiate()
	
	# 2. Adiciona a cena ao container primeiro para garantir a árvore de nós
	scene_container.add_child(active_scene)
	
	# 3. Conecta os sinais procurando o LevelManager nos nós filhos
	var level_manager = active_scene.get_node_or_null("LevelManager")
	
	if level_manager:
		if level_manager.has_signal("scene_finished"):
			level_manager.scene_finished.connect(_on_current_scene_finished)
		if level_manager.has_signal("reload"):
			level_manager.reload.connect(_on_current_scene_reload)
	else:
		# Fallback para cenas de corte (cutscenes) ou menus direto no nó raiz
		if active_scene.has_signal("scene_finished"):
			active_scene.scene_finished.connect(_on_current_scene_finished)
		if active_scene.has_signal("reload"):
			active_scene.reload.connect(_on_current_scene_reload)
			
	# 4. Fade In (Anima o alpha para 0.0 para revelar a nova cena)
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, fade_duration)

# --- EVENTOS DE TÉRMINO DA CENA ---

func _on_current_scene_finished() -> void:
	_start_fade_out_transition(swap_to_next_scene)

func _on_current_scene_reload() -> void:
	_start_fade_out_transition(reload_current_scene)

# --- LÓGICA DE TRANSIÇÃO E FLUXO ---

func _start_fade_out_transition(acao_final: Callable) -> void:
	var tween = create_tween()
	
	# 1. Fade Out: Anima a transparência para 1.0 (tela preta)
	tween.tween_property(fade_rect, "color:a", 1.0, fade_duration)
	
	# 2. Espera o tempo de tela preta especificado
	tween.tween_interval(tempo_tela_preta)
	
	# 3. Executa o callback final
	tween.tween_callback(acao_final)

func swap_to_next_scene() -> void:
	if active_scene:
		# Desconecta o LevelManager antigo antes de remover para evitar sinais fantasmas
		var level_manager = active_scene.get_node_or_null("LevelManager")
		if level_manager:
			if level_manager.scene_finished.is_connected(_on_current_scene_finished):
				level_manager.scene_finished.disconnect(_on_current_scene_finished)
			if level_manager.reload.is_connected(_on_current_scene_reload):
				level_manager.reload.disconnect(_on_current_scene_reload)
		
		scene_container.remove_child(active_scene)
		active_scene.queue_free()
		active_scene = null # Zera a referência física
		
	# Reseta as travas globais para a nova fase iniciar limpa
	Game.game_paused = false
	Game.skip_cutscenes = false
	
	current_index += 1
	load_scene(current_index)

func reload_current_scene() -> void:
	if active_scene:
		# Desconecta o LevelManager antigo
		var level_manager = active_scene.get_node_or_null("LevelManager")
		if level_manager:
			if level_manager.scene_finished.is_connected(_on_current_scene_finished):
				level_manager.scene_finished.disconnect(_on_current_scene_finished)
			if level_manager.reload.is_connected(_on_current_scene_reload):
				level_manager.reload.disconnect(_on_current_scene_reload)
				
		scene_container.remove_child(active_scene)
		active_scene.queue_free()
		active_scene = null # Zera a referência física
		
	# Reseta as travas globais para o reload funcionar e pula as animações iniciais
	Game.game_paused = false
	Game.skip_cutscenes = true 
	
	load_scene(current_index)
