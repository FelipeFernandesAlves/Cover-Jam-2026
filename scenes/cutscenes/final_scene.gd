extends Node2D

@onready var falas1 = $CanvasLayer/falas1
@onready var falas2 = $CanvasLayer/falas2
@onready var falas3 = $CanvasLayer/falas3
@onready var falas4 = $CanvasLayer/falas4

@onready var estrelas_animation : AnimatedSprite2D = $AnimatedSprite2D
@onready var star_lamb = $StarLamb
@onready var star_mage = $StarMage
@onready var cloudes = $Cloudes
@onready var stars_no_sky = $StarsNoSky

func _ready() -> void:
	# 1. Esconde todos os elementos visuais no começo
	estrelas_animation.visible = false
	star_lamb.visible = false
	star_mage.visible = false
	cloudes.visible = false
	stars_no_sky.visible = false
	
	# 2. Centraliza e ajusta o tamanho com base na tela inicial
	_recalcular_posicoes()
	
	# 3. Conecta o sinal que avisa quando a tela muda de tamanho
	get_viewport().size_changed.connect(_recalcular_posicoes)
	
	# 4. Conecta os sinais da cutscene
	falas1.all_finished.connect(_on_falas1_finished)
	estrelas_animation.animation_finished.connect(_on_estrelas_finished)
	falas2.all_finished.connect(_on_falas2_finished)
	falas3.all_finished.connect(_on_falas3_finished)
	
	# Começa a cena
	falas1.start_sequence()


# --- FUNÇÕES PARA RESPONSIVIDADE (TELA E TAMANHO) ---

func _recalcular_posicoes() -> void:
	_preparar_sprite(estrelas_animation)
	_preparar_sprite(star_lamb)
	_preparar_sprite(star_mage)
	_preparar_sprite(cloudes)
	_preparar_sprite(stars_no_sky)

func _preparar_sprite(sprite: Node2D) -> void:
	var tela = get_viewport_rect().size
	sprite.position = tela / 2.0
	
	var tamanho_textura = Vector2.ZERO
	if sprite is Sprite2D and sprite.texture:
		tamanho_textura = sprite.texture.get_size()
	elif sprite is AnimatedSprite2D and sprite.sprite_frames:
		tamanho_textura = sprite.sprite_frames.get_frame_texture(sprite.animation, 0).get_size()
		
	if tamanho_textura != Vector2.ZERO:
		var altura_desejada = tela.y * 0.8 
		var fator_escala = altura_desejada / tamanho_textura.y
		sprite.scale = Vector2(fator_escala, fator_escala)


# --- SISTEMA DE TRANSIÇÃO (FADE IN E FADE OUT) ---

func _fazer_transicao(saindo: Array[Node2D], entrando: Array[Node2D], acao_seguinte: Callable) -> void:
	var tween = create_tween()
	var duracao_fade = 1.0 # 1 segundo para cada ação
	
	# 1. Fade OUT (se houver alguém para sair)
	if saindo.size() > 0:
		tween.set_parallel(true) # Faz sumir todos ao mesmo tempo
		for s in saindo:
			tween.tween_property(s, "modulate:a", 0.0, duracao_fade)
		tween.set_parallel(false)
		
		# Desativa a visibilidade depois que ficarem transparentes
		for s in saindo:
			tween.tween_callback(func(): s.visible = false)

	# 2. Fade IN (se houver alguém para entrar)
	if entrando.size() > 0:
		tween.set_parallel(true)
		for e in entrando:
			e.modulate.a = 0.0 # Garante que comece transparente
			e.visible = true
			tween.tween_property(e, "modulate:a", 1.0, duracao_fade)
		tween.set_parallel(false)
	
	# 3. Chama a próxima função da história (textos, etc)
	if acao_seguinte.is_valid():
		tween.tween_callback(acao_seguinte)


# --- ETAPAS DA CUTSCENE ---

func _on_falas1_finished() -> void:
	# Ninguém sai [ ], Entra as estrelas, e depois dá play na animação
	_fazer_transicao([], [estrelas_animation], func(): estrelas_animation.play("default"))

func _on_estrelas_finished() -> void:
	await get_tree().create_timer(2.0).timeout
	# Sai as estrelas, Entra o StarLamb, e depois inicia a fala 2
	_fazer_transicao([estrelas_animation], [star_lamb], func(): falas2.start_sequence())

func _on_falas2_finished() -> void:
	# Sai o StarLamb, Entra a StarMage, e depois inicia a fala 3
	_fazer_transicao([star_lamb], [star_mage], func(): falas3.start_sequence())

func _on_falas3_finished() -> void:
	# Sai a StarMage, Entram Cloudes e StarsNoSky juntos
	_fazer_transicao([star_mage], [cloudes, stars_no_sky], func(): 
		
		# Efeito nas Estrelas: Move apenas 4 pixels, leva 4 segundos, começa subindo (false)
		_adicionar_efeito_flutuante(stars_no_sky, 4.0, 4.0, false)
		
		# Efeito nas Nuvens: Move 6 pixels, leva 5 segundos, começa descendo (true)
		# O fato de terem tempos e inícios diferentes garante que nunca fiquem sincronizadas!
		_adicionar_efeito_flutuante(cloudes, 6.0, 5.0, true)
		
		# Continua a história
		falas4.start_sequence()
	)
	
# --- EFEITOS VISUAIS ---

func _adicionar_efeito_flutuante(sprite: Node2D, distancia: float, tempo: float, comecar_descendo: bool = false) -> void:
	var tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Define se a imagem vai subir ou descer primeiro
	var direcao1 = distancia if comecar_descendo else -distancia
	var direcao2 = -distancia if comecar_descendo else distancia
	
	# Vai suavemente para um lado
	tween.tween_property(sprite, "position:y", direcao1, tempo).as_relative()
	
	# Volta suavemente para o lugar original
	tween.tween_property(sprite, "position:y", direcao2, tempo).as_relative()
	
	
