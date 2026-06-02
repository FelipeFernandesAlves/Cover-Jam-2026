extends Control
class_name FadeTextUI

signal finished

@onready var bg: PanelContainer = $PanelContainer
@export var content : FadeTextContent
@export var label: Label

func _ready() -> void:
	# Garante que o texto comece invisível
	bg.modulate.a = 0.0
	label.modulate.a = 0.0

# Função para iniciar a animação do texto
func play(new_content: FadeTextContent) -> void:
	content = new_content
	label.text = content.label
	label.modulate.a = 0.0 # Começa transparente
	bg.modulate.a = 0.0
	
	# Cria o Tween (Godot 4)
	var tween = create_tween()
	var tween_bg = create_tween()
	
	# 1. Aparecer (Fade In) no tempo de fade_duration
	tween.tween_property(label, "modulate:a", 1.0, content.fade_duration)
	tween_bg.tween_property(bg, "modulate:a", 1.0, content.fade_duration)
	
	# 2. Ficar na tela (Espera) pelo tempo de duration
	tween.tween_interval(content.duration)
	tween_bg.tween_interval(content.duration)
	
	# 3. Sumir (Fade Out) no tempo de fade_duration
	tween.tween_property(label, "modulate:a", 0.0, content.fade_duration)
	tween_bg.tween_property(bg, "modulate:a", 0.0, content.fade_duration)
	
	# 4. Quando o Tween terminar todas as etapas acima, emite o sinal
	tween.finished.connect(func(): finished.emit())

func _process(_delta: float) -> void:
	pass	
