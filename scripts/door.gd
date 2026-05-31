class_name Door
extends GridVisual

@onready var win_area: Area2D = $WinArea
@onready var door_back: Sprite2D = $DoorBack
var tween: Tween = null
var filling: bool = false
signal light_beam_touched()

func _ready() -> void:
	door_back.scale.y = 0

func fill():
	if (filling): return
	
	if (tween):
		tween.kill()

	filling = true
	light_beam_touched.emit()
	tween = create_tween()
	tween.tween_property(door_back, "scale:y", 1.0, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
