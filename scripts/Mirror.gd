extends Reflective

@export var move_audio: AudioStreamPlayer

func _ready():
	super()
	entity_moved.connect(func():
		move_audio.play()
	)

	if (!sprites): return
	
	match reflect_dir:
		REFLECT_DIRECTION.NW: 
			sprites.frame = 0
		REFLECT_DIRECTION.NE: 
			sprites.frame = 1 
		REFLECT_DIRECTION.SE: 
			sprites.frame = 2
		REFLECT_DIRECTION.SW: 
			sprites.frame = 4
