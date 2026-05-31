extends PanelContainer

signal dialog_finished()

# Criamos uma variável que aceita o nosso recurso customizado
@export var content: DialogContent

@export var letter_interval: float = 0.03

@onready var main_hbox : HBoxContainer = $HBoxContainer
@onready var texture_rect: TextureRect = $HBoxContainer/EmoteBox/TextureRect
@onready var label: Label = $HBoxContainer/HBoxContainer/Label

@export var aprendiz_texture : AtlasTexture
@export var mestre_texture : AtlasTexture

const FACE_WIDTH = 48
const FACE_HEIGHT = 47
var text_tween: Tween

func _ready() -> void:
	if content:
		atualizar_ui()

func atualizar_ui() -> void:
	# Define a imagem e o texto
	if content.personagem == DialogContent.Personagem.APRENDIZ:
		texture_rect.texture = aprendiz_texture
	else:
		texture_rect.texture = mestre_texture
	set_character_emotion(content.emotion)
	label.text = content.texto
	main_hbox.layout_direction = LayoutDirection.LAYOUT_DIRECTION_LTR if content.image_direction == content.ImageDirection.LEFT else LayoutDirection.LAYOUT_DIRECTION_RTL
	
	# Esconde todo o texto antes de começar a animação
	label.visible_ratio = 0.0
	
	# Calcula quanto tempo a animação toda vai durar para manter uma velocidade constante
	var total_duration = label.text.length() * letter_interval
	
	# Cria a animação
	text_tween = create_tween()
	
	# Anima a propriedade "visible_ratio" do label até 1.0 (100%)
	text_tween.tween_property(label, "visible_ratio", 1.0, total_duration)

func set_character_emotion(emotion: DialogContent.Emotion):
	# Pegamos o AtlasTexture atual
	var atlas_tex = texture_rect.texture as AtlasTexture
	
	if atlas_tex:
		# Calculamos a posição X baseada no índice da emoção.
		# Isso assume que seus rostos estão alinhados horizontalmente no sprite sheet.
		var new_x_position = int(emotion) * FACE_WIDTH
		
		# Atualizamos a região para mostrar o rosto correto
		atlas_tex.region = Rect2(new_x_position, 0, FACE_WIDTH, FACE_HEIGHT)
	
func _input(event: InputEvent) -> void:
	# Se o jogador clicar com o botão esquerdo do mouse ou apertar "Espaço/Enter"
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		
		# Verifica se a animação ainda está rodando
		if text_tween and text_tween.is_running():
			# Mata a animação e mostra o texto completo instantaneamente
			text_tween.kill()
			label.visible_ratio = 1.0
		else:
			dialog_finished.emit()
			#queue_free()
