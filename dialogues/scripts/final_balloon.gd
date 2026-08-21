class_name FinalDialogueBalloon
extends DialogueBalloon

@export var balloon_root: Control
var tween: Tween

signal animation_end()

func _ready() -> void:
	balloon_root.modulate.a = 0.0

func hide_dialogue():
	if (tween):
		tween.kill()

	tween = create_tween()
	tween.tween_property(balloon_root, "modulate:a", 0.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.finished.connect(func(): 
		animation_end.emit()
		visible = false
		)

func show_dialogue():
	if (tween):
		tween.kill()

	character_label.text = ""
	dialogue_label.text = ""
	balloon_root.modulate.a = 0.0
	visible = true

	tween = create_tween()
	tween.tween_property(balloon_root, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.finished.connect(func(): 
		animation_end.emit()
		)
