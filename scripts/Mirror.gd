extends Reflective

@export var move_audio: AudioStreamPlayer

func _ready():
	super()
	entity_moved.connect(func():
		move_audio.play()
	)
