extends Node
class_name FadeTextManager

signal all_finished

@export var sequence : Array[FadeTextContent]
var fade_ui_scene = preload("res://scenes/cutscenes/fade_text.tscn")

var current_index : int = 0
var fade_ui_instance : FadeTextUI 

func _ready() -> void:
	# Apenas prepara a UI, mas NÃO começa a tocar a sequência
	fade_ui_instance = fade_ui_scene.instantiate() as FadeTextUI
	add_child(fade_ui_instance)
	
	# Já deixamos o sinal conectado e pronto para quando for usado
	fade_ui_instance.finished.connect(_on_text_finished)

# --- NOVA FUNÇÃO PARA COMEÇAR ---
func start_sequence() -> void:
	# Zeramos o índice caso você queira rodar a sequência mais de uma vez no futuro
	current_index = 0 
	
	# Verifica se há algo para tocar antes de tentar começar
	if sequence.size() > 0:
		_play_next()
	else:
		push_warning("A sequência de FadeTextManager está vazia!")

func _play_next() -> void:
	if current_index < sequence.size():
		var next_content = sequence[current_index]
		fade_ui_instance.play(next_content)
		current_index += 1
	else:
		all_finished.emit()

func _on_text_finished() -> void:
	_play_next()
