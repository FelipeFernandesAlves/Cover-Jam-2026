extends Node2D

@export var dialogue_balloon: FinalDialogueBalloon
@export var credits: Control
@export_file(".tscn") var restarting_scene: String
@export var sine: Sine

@export var stars_animation : AnimatedSprite2D
@export var star_lamb: Sprite2D
@export var star_mage: Sprite2D
@export var clouds: Sprite2D
@export var stars_no_sky: Sprite2D

var sprites: Dictionary[String, Node2D]
var starts_initial_pos: Vector2
var can_restart: bool

func _ready() -> void:
	# 1. Esconde todos os elementos visuais no começo
	stars_animation.visible = false
	star_lamb.visible = false
	star_mage.visible = false
	stars_no_sky.visible = false
	clouds.visible = true
	credits.visible = false
	credits.modulate.a = 0.0

	# 2. Centraliza e ajusta o tamanho com base na tela inicial
	_recalcular_posicoes()
	
	# 3. Conecta o sinal que avisa quando a tela muda de tamanho
	get_viewport().size_changed.connect(_recalcular_posicoes)
	dialogue_balloon.show_dialogue()
	dialogue_balloon.start()

	sprites = {
		"stars_animation": stars_animation,
		"star_lamb": star_lamb,
		"star_mage": star_mage,
		"clouds": clouds,
		"stars_no_sky": stars_no_sky
	}

	# # 4. Conecta os sinais da cutscene
	# falas1.all_finished.connect(_on_falas1_finished)
	# estrelas_animation.animation_finished.connect(_on_estrelas_finished)
	# falas2.all_finished.connect(_on_falas2_finished)
	# falas3.all_finished.connect(_on_falas3_finished)
	
	# Começa a cena
	# falas1.start_sequence()


# --- FUNÇÕES PARA RESPONSIVIDADE (TELA E TAMANHO) ---

func _process(_delta: float) -> void:
	if (stars_no_sky && starts_initial_pos):
		stars_no_sky.position = starts_initial_pos + Vector2(0, sine.get_sine())
	
	if (can_restart && Input.is_action_just_pressed("restart_level")):
		get_tree().change_scene_to_file(restarting_scene)

func _recalcular_posicoes() -> void:
	_preparar_sprite(stars_animation)
	_preparar_sprite(star_lamb)
	_preparar_sprite(star_mage)
	_preparar_sprite(clouds)
	_preparar_sprite(stars_no_sky)

func _preparar_sprite(sprite: Node2D) -> void:
	var tela = get_viewport_rect().size
	sprite.position = tela / 2.0

	if (sprite == stars_no_sky):
		starts_initial_pos = sprite.global_position
	
	var tamanho_textura = Vector2.ZERO
	if sprite is Sprite2D and sprite.texture:
		tamanho_textura = sprite.texture.get_size()
	elif sprite is AnimatedSprite2D and sprite.sprite_frames:
		tamanho_textura = sprite.sprite_frames.get_frame_texture(sprite.animation, 0).get_size()
		
	if tamanho_textura != Vector2.ZERO:
		var altura_desejada = tela.y * 0.8 
		var fator_escala = altura_desejada / tamanho_textura.y
		sprite.scale = Vector2(fator_escala, fator_escala)

func show_dialogue_balloon():
	dialogue_balloon.show_dialogue()
	await dialogue_balloon.animation_end

func hide_dialogue_balloon():
	dialogue_balloon.hide_dialogue()
	await dialogue_balloon.animation_end

func show_stars():
	stars_animation.show()
	stars_animation.play("default")
	await stars_animation.animation_finished

func hide_sprite(sprite_name: String):
	match sprite_name:
		"stars_animation":
			stars_animation.hide()
		"star_lamb":
			star_lamb.hide()
		"star_mage":
			star_mage.hide()
		"clouds":
			clouds.hide()
		"stars_no_sky":
			stars_animation.hide()

func show_sprite(sprite_name: String):
	match sprite_name:
		"stars_animation":
			stars_animation.show()
		"star_lamb":
			star_lamb.show()
		"star_mage":
			star_mage.show()
		"clouds":
			clouds.show()
		"stars_no_sky":
			stars_animation.show()

func change_sprites(saindo: String, entrando: String) -> void:
	var tween = create_tween()
	var duracao_fade = 0.5

	var scene_in: Node2D = sprites.get(entrando)
	var scene_out: Node2D = sprites.get(saindo)

	if scene_out:
		tween.tween_property(scene_out, "modulate:a", 0.0, duracao_fade).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_callback(func(): scene_out.visible = false)

	if scene_in:
		scene_in.modulate.a = 0.0 
		scene_in.visible = true
		tween.tween_property(scene_in, "modulate:a", 1.0, duracao_fade).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	await tween.finished

func show_credits():
	credits.modulate.a = 0.0
	credits.show()

	var tween = create_tween()
	tween.tween_property(credits, "modulate:a", 1.0, 1.0)
	tween.finished.connect(func():
		can_restart = true
		)

# --- ETAPAS DA CUTSCENE ---

# func _on_falas1_finished() -> void:
# 	# Ninguém sai [ ], Entra as estrelas, e depois dá play na animação
# 	_fazer_transicao([], [estrelas_animation], func(): estrelas_animation.play("default"))

# func _on_estrelas_finished() -> void:
# 	await get_tree().create_timer(2.0).timeout
# 	# Sai as estrelas, Entra o StarLamb, e depois inicia a fala 2
# 	_fazer_transicao([estrelas_animation], [star_lamb], func(): falas2.start_sequence())

# func _on_falas2_finished() -> void:
# 	# Sai o StarLamb, Entra a StarMage, e depois inicia a fala 3
# 	_fazer_transicao([star_lamb], [star_mage], func(): falas3.start_sequence())

# func _on_falas3_finished() -> void:
# 	# Sai a StarMage, Entram Cloudes e StarsNoSky juntos
# 	_fazer_transicao([star_mage], [cloudes, stars_no_sky], func(): 
		
# 		# Efeito nas Estrelas: Move apenas 4 pixels, leva 4 segundos, começa subindo (false)
# 		_adicionar_efeito_flutuante(stars_no_sky, 4.0, 4.0, false)
		
# 		# Efeito nas Nuvens: Move 6 pixels, leva 5 segundos, começa descendo (true)
# 		# O fato de terem tempos e inícios diferentes garante que nunca fiquem sincronizadas!
# 		_adicionar_efeito_flutuante(cloudes, 6.0, 5.0, true)
		
# 		# Continua a história
# 		falas4.start_sequence()
# 	)
	
# # --- EFEITOS VISUAIS ---

# func _adicionar_efeito_flutuante(sprite: Node2D, distancia: float, tempo: float, comecar_descendo: bool = false) -> void:
# 	var tween = create_tween().set_loops()
# 	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
# 	# Define se a imagem vai subir ou descer primeiro
# 	var direcao1 = distancia if comecar_descendo else -distancia
# 	var direcao2 = -distancia if comecar_descendo else distancia
	
# 	# Vai suavemente para um lado
# 	tween.tween_property(sprite, "position:y", direcao1, tempo).as_relative()
	
# 	# Volta suavemente para o lugar original
# 	tween.tween_property(sprite, "position:y", direcao2, tempo).as_relative()
	
	
