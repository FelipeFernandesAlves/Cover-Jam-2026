extends PanelContainer

signal dialog_finished()

# Criamos uma variável que aceita o nosso recurso customizado
@export var content: DialogContent

@export var letter_interval: float = 0.03

@onready var main_hbox : HBoxContainer = $HBoxContainer
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var label: Label = $HBoxContainer/HBoxContainer/Label

var text_tween: Tween

func _ready() -> void:
	if content:
		atualizar_ui()

func atualizar_ui() -> void:
	# Define a imagem e o texto
	texture_rect.texture = content.imagem
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
