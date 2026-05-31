extends Node
class_name GridState

# Sinais que a parte visual vai escutar para rodar as animações
signal entity_moved(entity: GridEntityData, from_pos: Vector2i, to_pos: Vector2i)
signal player_damaged(amount: int)

enum CellType { EMPTY, WALL, MOVABLE, ENEMY, PLAYER }

static var CELL_SIZE : int = 32
@export var collision_tile : TileMapLayer
var grid_size : Vector2i = Vector2i.ZERO

# Dicionário de estado: Vector2i -> GridEntityData
var grid_data: Dictionary = {}

func _ready() -> void:
	grid_size = collision_tile.get_used_rect().size
	_generate_colision_cells()

func _generate_colision_cells() -> void:
	for cell in collision_tile.get_used_cells():		
		var wall_data = GridEntityData.new(CellType.WALL, null)
		register_entity(Vector2i(cell.x, cell.y), wall_data)
		

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
	
# Verifica se uma entidade consegue se mover para a direção desejada (sem alterar a grid).
# Útil para prever se o objeto puxado será bloqueado.
func can_entity_move(from_pos: Vector2i, direction: Vector2i) -> bool:
	var target_pos = from_pos + direction
	
	if is_wall(target_pos):
		return false
		
	var target_type = get_cell_type(target_pos)
	
	# Se bater em um inimigo ou no próprio jogador, o movimento trava
	if target_type == CellType.ENEMY or target_type == CellType.PLAYER:
		return false
		
	# Se bater em outro bloco movível, faz a checagem em cadeia
	if target_type == CellType.MOVABLE:
		return can_entity_move(target_pos, direction)
		
	# Retorna true se a célula alvo final estiver vazia
	return target_type == CellType.EMPTY

# Tenta mover o player e arrastar junto a entidade que está na 'facing_direction'
func try_pull_entity(from_pos: Vector2i, move_direction: Vector2i, facing_direction: Vector2i) -> bool:
	# Posição onde esperamos que o objeto segurado esteja
	var grab_pos = from_pos + facing_direction
	
	# 1. Verifica se a célula na nossa frente tem algo que pode ser puxado
	if get_cell_type(grab_pos) != CellType.MOVABLE:
		# Se não tem nada (ou é parede/inimigo), age como movimento normal
		return try_move_entity(from_pos, move_direction)
		
	# 2. Se for um empurrão normal para frente, usamos a lógica padrão que já resolve a cadeia
	if move_direction == facing_direction:
		return try_move_entity(from_pos, move_direction)
		
	var object_target = grab_pos + move_direction
	
	# 3. Validamos se o objeto pode se mover na direção desejada antes de mover o player.
	# Se o puxão for para trás (o alvo do objeto é o espaço do player), 
	# nós sabemos que o espaço ficará vazio, então não bloqueamos.
	# Se for movimento lateral, fazemos a previsão com `can_entity_move`.
	if object_target != from_pos:
		if not can_entity_move(grab_pos, move_direction):
			# Há algo bloqueando o caminho do objeto. O jogador fica parado.
			return false
			
	# 4. Agora que sabemos que o objeto pode mover, tentamos mover o jogador.
	var player_moved = try_move_entity(from_pos, move_direction)
	
	# 5. Se o jogador moveu com sucesso, arrastamos o objeto para acompanhar
	if player_moved:
		if object_target == from_pos:
			# Puxão para trás: move a caixa manualmente para a célula que o player desocupou
			var pulled_entity = grid_data[grab_pos]
			grid_data.erase(grab_pos)
			grid_data[from_pos] = pulled_entity
			
			# Avisa as animações
			entity_moved.emit(pulled_entity, grab_pos, from_pos)
		else:
			# Puxão lateral (Strafing): o objeto e o player andam em paralelo.
			# Chamamos a própria try_move_entity para o objeto, para que
			# ele também empurre em cadeia outras caixas que estejam do lado dele!
			try_move_entity(grab_pos, move_direction)
			
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
