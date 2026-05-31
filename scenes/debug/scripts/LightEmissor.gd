extends GridVisual

@onready var light_beam: LightBeam = $LightBeam

func _physics_process(_delta: float) -> void:
	light_beam.is_casting = Input.is_action_pressed("ui_accept")
