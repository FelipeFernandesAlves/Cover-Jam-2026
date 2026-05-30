extends Node2D
class_name GridVisual

@export_group("Configurações de Grid")
@export var grid_state: GridState # Arraste o nó lógico aqui
@export var initial_grid_pos: Vector2i
@export var type: GridState.CellType

@export_group("Animação")
@export var move_duration: float = 0.15
@export var cell_size: int = 32 # Deve ser o mesmo do seu TileMap

var current_grid_pos: Vector2i
var entity_data: GridEntityData

func _ready():
	# 1. Posicionamento Inicial
	current_grid_pos = initial_grid_pos
	position = get_centered_pixel_position(current_grid_pos)	
	# 2. Registrar na Lógica
	entity_data = GridEntityData.new(type, self)
	grid_state.register_entity(current_grid_pos, entity_data)
	
	# 3. Conectar ao sinal de movimento da Grid
	grid_state.entity_moved.connect(_on_entity_moved)

func _on_entity_moved(entity: GridEntityData, _from: Vector2i, to: Vector2i):
	# Se a grid me disse que EU (meu dado) mudei de lugar:
	if entity == entity_data:
		current_grid_pos = to
		animate_to_position(get_centered_pixel_position(to))

func get_centered_pixel_position(grid_pos: Vector2i) -> Vector2:
	# Multiplica pela posição da grid e soma metade do tamanho da célula nos eixos X e Y
	var offset = Vector2(cell_size / 2.0, cell_size / 2.0)
	return Vector2(grid_pos * cell_size) + offset

func animate_to_position(target_pos: Vector2):
	var tween = create_tween()
	# Transição "Back" ou "Sine" dá um feeling mais polido
	tween.tween_property(self, "position", target_pos, move_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
