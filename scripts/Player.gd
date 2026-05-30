extends GridVisual

var is_animating: bool = false
var facing_direction: Vector2i = Vector2i.DOWN # Guarda para onde o player está olhando

func _process(_delta):
	if is_animating: return
	
	var move_dir = Vector2i.ZERO
	if Input.is_action_just_pressed("ui_right"): move_dir = Vector2i.RIGHT
	elif Input.is_action_just_pressed("ui_left"): move_dir = Vector2i.LEFT
	elif Input.is_action_just_pressed("ui_up"): move_dir = Vector2i.UP
	elif Input.is_action_just_pressed("ui_down"): move_dir = Vector2i.DOWN
	
	if move_dir != Vector2i.ZERO:
		var is_grabbing = Input.is_action_pressed("ui_select") # Botão Espaço
		
		# Só atualizamos a direção do olhar se NÃO estivermos segurando o espaço.
		# Se estiver segurando, o olhar fica "travado" no objeto.
		if not is_grabbing:
			facing_direction = move_dir
			
		# Envia o pedido apropriado para o GridState
		if is_grabbing:
			if grid_state.try_pull_entity(current_grid_pos, move_dir, facing_direction):
				_travar_input_temporariamente()
		else:
			if grid_state.try_move_entity(current_grid_pos, move_dir):
				_travar_input_temporariamente()

func _travar_input_temporariamente():
	is_animating = true
	await get_tree().create_timer(move_duration).timeout
	is_animating = false
