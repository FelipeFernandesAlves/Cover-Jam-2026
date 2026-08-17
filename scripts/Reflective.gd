class_name Reflective
extends GridVisual

enum REFLECT_DIRECTION { NW, NE, SE, SW }

@export var reflect_dir: REFLECT_DIRECTION = REFLECT_DIRECTION.NW:
	set = _set_reflect_dir
@export var reflect_point: Node2D
@export var sprites: AnimatedSprite2D

func _ready():
	super()
	_set_reflect_dir(reflect_dir)

func get_reflect_direction(impact_dir: Vector2) -> Vector2:
	var possible_directions = _get_possible_directions()
	var dir = -impact_dir
	if (dir in possible_directions):
		possible_directions.erase(dir)
		return possible_directions[0]
	return Vector2.ZERO

func _get_possible_directions() -> Array[Vector2]:
	match reflect_dir:
		REFLECT_DIRECTION.NW: return [Vector2.UP, Vector2.LEFT]
		REFLECT_DIRECTION.NE: return [Vector2.UP, Vector2.RIGHT]
		REFLECT_DIRECTION.SE: return [Vector2.DOWN, Vector2.RIGHT]
		REFLECT_DIRECTION.SW: return [Vector2.DOWN, Vector2.LEFT]
	return []

func _set_reflect_dir(value):
	if (reflect_dir == value):
		return
		
	reflect_dir = value

