extends TextureRect
#
## Usamos @export para que essas variáveis apareçam no painel Inspector,
## exatamente como os "sliders" da simulação anterior!
#@export var amplitude: float = 10.0 # O quanto ele sobe e desce (em pixels)
#@export var velocidade: float = 3.0 # Quão rápido é o movimento
#
## Variáveis internas para controlar o movimento
#var start_y: float
#var tempo_decorrido: float = 0.0
#
#func _ready():
	## Quando o jogo começa, salvamos a posição vertical (Y) original.
	## Como você centralizou ele no passo anterior, este é o ponto zero perfeito.
	#start_y = position.y
#
#func _process(delta: float):
	## O delta é o tempo entre os quadros. Somamos ele para o tempo passar.
	#tempo_decorrido += delta * velocidade
	#
	## Aqui acontece a mágica: a função sin() cria uma onda que vai de -1 a 1.
	## Multiplicamos isso pela amplitude e somamos à posição inicial.
	#position.y = start_y + (sin(tempo_decorrido) * amplitude)
