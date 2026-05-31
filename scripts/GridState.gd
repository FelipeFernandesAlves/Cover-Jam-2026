extends Node
class_name GridState

const WALL = preload("uid://cuquyr68wyckr")

signal entity_moved(entity: GridEntityData, from_pos: Vector2i, to_pos: Vector2i)
signal player_damaged(amount: int)

enum CellType { EMPTY, WALL, MOVABLE, ENEMY, PLAYER }

static var CELL_SIZE : int = 16
@export var collision_tile : TileMapLayer
@export var hide_col: bool
var grid_size : Vector2i = Vector2i.ZERO

# Dicionário de estado: Vector2i -> GridEntityData
var grid_data: Dictionary = {}

func _ready() -> void:
	Game.grid_state = self
	grid_size = collision_tile.get_used_rect().size
	_generate_colision_cells()
	collision_tile.visible = !hide_col

func _generate_colision_cells() -> void:
	for cell in collision_tile.get_used_cells():
		var wall: GridVisual = WALL.instantiate()
		var wall_data = GridEntityData.new(CellType.WALL, null)
		wall.entity_data = wall_data
		wall.global_position = Vector2(cell.x, cell.y) * CELL_SIZE
		register_entity(Vector2i(cell.x, cell.y), wall_data)
		add_child(wall)
		
# Registra uma entidade na grid lógica (sobrescreve automaticamente se já houver algo)
func register_entity(pos: Vector2i, entity: GridEntityData):
	grid_data[pos] = entity

# O coração do sistema: Tenta mover uma entidade em uma direção
func try_move_entity(from_pos: Vector2i, direction: Vector2i) -> bool:
	var target_pos = from_pos + direction
	
	# 1. Se o alvo for uma parede física ou limite do mapa, bloqueia imediatamente
	if is_wall(target_pos):
		return false
		
	# 2. Se o alvo tiver um inimigo e quem está movendo for o Player
	if get_cell_type(target_pos) == CellType.ENEMY and get_cell_type(from_pos) == CellType.PLAYER:
		player_damaged.emit(1) # Aplica dano
		return false # Bloqueia o movimento

	# 3. Se o alvo tiver algo movível, precisamos checar se a cadeia inteira pode se mover
	if get_cell_type(target_pos) == CellType.MOVABLE:
		# Chamada recursiva: tenta mover o objeto da frente primeiro
		var can_push = try_move_entity(target_pos, direction)
		if not can_push:
			return false # Se o objeto da frente colidir com uma parede, toda a cadeia para

	# 4. Se a célula alvo estiver vazia (ou acabou de ficar vazia pelo empurrão acima)
	if get_cell_type(target_pos) == CellType.EMPTY:
		# Executa a mudança no estado lógico
		var entity = grid_data[from_pos]
		grid_data.erase(from_pos)
		grid_data[target_pos] = entity
		
		# Avisa o mundo visual que a entidade mudou de lugar na lógica
		entity_moved.emit(entity, from_pos, target_pos)
		return true
		
	return false

# Tenta mover o player e arrastar junto a entidade que está na 'facing_direction'
func try_pull_entity(from_pos: Vector2i, move_direction: Vector2i, facing_direction: Vector2i) -> bool:
	# Posição onde esperamos que o objeto segurado esteja
	var grab_pos = from_pos + facing_direction
	
	# 1. Verifica se a célula na nossa frente tem algo que pode ser puxado
	if get_cell_type(grab_pos) != CellType.MOVABLE:
		# Se não tem nada (ou é uma parede/inimigo), age como um movimento normal
		return try_move_entity(from_pos, move_direction)
		
	# 2. Se for um empurrão normal para frente (mesmo segurando), não é um puxão.
	if move_direction == facing_direction:
		return try_move_entity(from_pos, move_direction)
		
	# 3. Tenta mover o jogador na direção desejada (de ré ou para os lados)
	# Isso vai processar toda a lógica de paredes e empurrões caso tenha algo atrás do jogador
	var player_moved = try_move_entity(from_pos, move_direction)
	
	# 4. Se o jogador conseguiu se mover, a célula 'from_pos' agora OBRIGATORIAMENTE está vazia.
	# Nós pegamos a caixa e colocamos na célula recém-desocupada.
	if player_moved:
		var pulled_entity = grid_data[grab_pos]
		grid_data.erase(grab_pos)
		grid_data[from_pos] = pulled_entity
		
		# Avisa as animações que a caixa mudou de lugar
		entity_moved.emit(pulled_entity, grab_pos, from_pos)
		return true
		
	return false

# Auxiliares de checagem
func get_cell_type(pos: Vector2i) -> CellType:
	if pos.x < 0 or pos.x >= grid_size.x or pos.y < 0 or pos.y >= grid_size.y:
		return CellType.WALL
		
	if not grid_data.has(pos): return CellType.EMPTY
	return grid_data[pos].type

func is_wall(pos: Vector2i) -> bool:
	return get_cell_type(pos) == CellType.WALL
