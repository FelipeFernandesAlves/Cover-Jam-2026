extends Container
signal dialog_finished()

# Criamos uma variável que aceita o nosso recurso customizado
@export var content: DialogContent

@export var letter_interval: float = 0.01

@onready var main_hbox : HBoxContainer = %DialogHBox
@onready var texture_rect: TextureRect = %DialogPortrait
@onready var label: Label = %DialogContent
@onready var dialog_title: Label = %DialogTitle

var text_tween: Tween

func _ready() -> void:
	if content:
		atualizar_ui()

func atualizar_ui() -> void:
	if (content.imagem):
		texture_rect.texture = content.imagem
	dialog_title.text = content.title
	label.text = content.texto
	main_hbox.layout_direction = LayoutDirection.LAYOUT_DIRECTION_LTR if content.image_direction == content.ImageDirection.LEFT else LayoutDirection.LAYOUT_DIRECTION_RTL

	label.visible_ratio = 0.0

	var total_duration = label.text.length() * letter_interval
	text_tween = create_tween()
	text_tween.tween_property(label, "visible_ratio", 1.0, total_duration)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dialog_interact"):
		if text_tween and text_tween.is_running():
			text_tween.kill()
			label.visible_ratio = 1.0
		else:
			dialog_finished.emit()
			queue_free()
