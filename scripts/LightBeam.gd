class_name LightBeam
extends RayCast2D

const LIGHT_BEAM = preload("uid://6hfxkgkhecgv")

@export var cast_speed := 1000.0
@export var max_length := 1400.0
@export var is_casting := false:
	set = _set_is_casting

@export var line_growth_time := 0.1
@export var line_color := Color.WHITE:
	set = _set_line_color

@export var impact_dir := Vector2.RIGHT:
	set = _set_impact_dir

@onready var line: Line2D = $Line
@onready var line_width := line.width
@onready var beam_particles: GPUParticles2D = $BeamParticles
@onready var collision_particles: GPUParticles2D = $CollisionParticles
@onready var casting_particles: GPUParticles2D = $CastingParticles

var tween: Tween = null
var next_beam: LightBeam = null

signal disappeared()

func _ready() -> void:
	_set_line_color(line_color)
	_set_is_casting(is_casting)
	_set_impact_dir(impact_dir)

func _physics_process(delta: float) -> void:
	target_position.x = move_toward(
		target_position.x,
		max_length,
		cast_speed * delta
	)

	var beam_end_position := target_position
	force_raycast_update()
	
	if (is_colliding()):
		beam_end_position = to_local(get_collision_point())
		var collider = get_collider()
		if (collider is Door && !collider.filling):
			collider.fill()
		
		if (collider is Reflective):
			var new_dir = collider.get_reflect_direction(impact_dir)
			beam_end_position = to_local(collider.reflect_point.global_position)
			if (!next_beam):
				if (new_dir != Vector2.ZERO):
					next_beam = LIGHT_BEAM.instantiate()
					next_beam.disappeared.connect(func():
						next_beam.queue_free()
						next_beam = null
						_disappear()
						)
					next_beam.line_color = line_color
					add_child(next_beam)
					next_beam.is_casting = true
					next_beam.impact_dir = new_dir 
					next_beam.global_position = collider.reflect_point.global_position
			else:
				next_beam.global_position = collider.reflect_point.global_position
		elif (next_beam):
			next_beam.disappeared.disconnect(_disappear)
			next_beam.queue_free()
			next_beam = null
	elif (next_beam):
		next_beam.disappeared.disconnect(_disappear)
		next_beam.queue_free()
		next_beam = null
	
	line.points[1] = beam_end_position
	var beam_start_position := line.points[0]
	beam_particles.position = beam_start_position + (beam_end_position - beam_start_position) * 0.5
	beam_particles.process_material.emission_box_extents.x = beam_end_position.distance_to(beam_start_position) * 0.1
	casting_particles.position = beam_start_position
	collision_particles.position = beam_end_position

func _appear() -> void:
	if (tween && tween.is_running()): 
		tween.kill()
	
	line.visible = true
	casting_particles.show()
	collision_particles.show()
	#beam_particles.show()
	tween = create_tween()
	tween.tween_property(line, "width", line_width, line_growth_time * 2.0).from(0.0)

func _disappear() -> void:
	if (tween && tween.is_running()):
		tween.kill()
	tween = create_tween()
	tween.tween_property(line, "width", 0.0, line_growth_time).from_current()
	tween.tween_callback(_on_disappear)

func _on_disappear():
	line.hide()
	disappeared.emit()
	casting_particles.hide()
	collision_particles.hide()
	beam_particles.hide()
	if (next_beam):
		next_beam.queue_free()
		next_beam = null

func _set_is_casting(value: bool):
	if (is_casting == value): 
		return
#oi felipe
	is_casting = value
	set_physics_process(is_casting)

	if (!value):
		target_position.x = 0.0
		if (!next_beam):
			_disappear()
		else:
			next_beam.is_casting = false
	else:
		_appear()

func _set_line_color(value: Color):
	line_color = value
	if (line != null):
		line.modulate = line_color
		casting_particles.modulate = line_color
		collision_particles.modulate = line_color
		beam_particles.modulate = line_color
		
func _set_impact_dir(value: Vector2):
	impact_dir = value
	look_at(global_position + impact_dir)
