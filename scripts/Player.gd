class_name Player
extends GridVisual

var is_animating: bool = false
@export var facing_direction: Vector2i = Vector2i.DOWN # Guarda para onde o player está olhando

@onready var death_particles: GPUParticles2D = $DeathParticles
@onready var death_light: PointLight2D = $DeathLight
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D

var move_state: String = "idle"

func _ready():
	super()
	death_light.texture_scale = 0.0

func _process(_delta):
	if is_animating: return
	if Game.game_paused: return
	
	var move_dir = Vector2i.ZERO
	if Input.is_action_just_pressed("right"): move_dir = Vector2i.RIGHT
	elif Input.is_action_just_pressed("left"): move_dir = Vector2i.LEFT
	elif Input.is_action_just_pressed("up"): move_dir = Vector2i.UP
	elif Input.is_action_just_pressed("down"): move_dir = Vector2i.DOWN

	if Input.is_action_just_pressed("look_right"): facing_direction = Vector2i.RIGHT
	elif Input.is_action_just_pressed("look_left"): facing_direction = Vector2i.LEFT
	elif Input.is_action_just_pressed("look_up"): facing_direction = Vector2i.UP
	elif Input.is_action_just_pressed("look_down"): facing_direction = Vector2i.DOWN
	
	if move_dir != Vector2i.ZERO:
		var is_grabbing = Input.is_action_pressed("grab") # Botão Espaço
		
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
	_handle_animation()

func _get_facing_name():
	match facing_direction:
		Vector2i.UP: return "back"
		Vector2i.DOWN: return "front"
		Vector2i.LEFT: return "left"
		Vector2i.RIGHT: return "right"
		_: return null

func _handle_animation():
	var facing_name = _get_facing_name()
	if (!facing_name):
		return
	
	if (facing_name == "left" || facing_name == "right"):
		sprite.flip_h = facing_name == "left"
		facing_name = "side"
	
	var animation_name = str(move_state, "_", facing_name)
	sprite.animation = animation_name

func _travar_input_temporariamente(): 
	is_animating = true
	await get_tree().create_timer(move_duration).timeout
	is_animating = false

func die():
	collision.set_deferred("disabled", true)
	sprite.hide()
	var tween = create_tween()
	tween.tween_property(death_light, "texture_scale", 1.0, 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	death_particles.restart()
