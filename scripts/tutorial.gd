class_name Tutorial
extends Control

@export var background: ColorRect
@export var tutorial_box: Container
@export var tab_container: TabContainer
@export var controls_label: RichTextLabel

@export var left_arrow: TextureRect
@export var right_arrow: TextureRect
@export var page_dots_parent: Control

@export var keyboard_next_icon: TextureRect
@export var gamepad_next_icon: TextureRect
@export var menu_audio: AudioStreamPlayer
@export var show_audio: AudioStreamPlayer

@export_file_path() var keyboard_push_icon: String
@export_file_path() var gamepad_push_icon: String

const ANIMATION_TIME := 0.75

var controls_original_text: String
var tween: Tween
var active: bool = false
var page_dots: Array[TextureRect] = []
var max_pages: int:
	get():
		return tab_container.get_tab_count()

signal tutorial_ended()
signal tutorial_started()

func _ready() -> void:
	for child in page_dots_parent.get_children():
		if (child is TextureRect):
			page_dots.append(child)
	
	controls_original_text = controls_label.text
	_format_control_icon()
	Game.gamepad_mode_changed.connect(_format_control_icon)

func show_tutorial():
	if (active):
		return

	if (tween && tween.is_valid()):
		tween.kill()

	change_page(0)
	background.modulate.a = 0.0
	tutorial_box.offset_transform_position.y = 400
	visible = true

	if (show_audio):
		show_audio.play()

	tween = create_tween()
	tween.tween_property(background, "modulate:a", 1.0, ANIMATION_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(tutorial_box, "offset_transform_position:y", 0.0, ANIMATION_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		await get_tree().create_timer(0.2).timeout
		active = true
		tutorial_started.emit()
		)
	
func hide_tutorial():
	if (!active):
		return
	
	if (tween && tween.is_valid()):
		tween.kill()
	
	active = false
	tween = create_tween()
	tween.tween_property(background, "modulate:a", 0.0, ANIMATION_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(tutorial_box, "offset_transform_position:y", 400.0, ANIMATION_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		Game.game_paused = false
		visible = false
		tutorial_ended.emit()
		)

func change_page(page_number: int):
	if (page_number == tab_container.current_tab):
		return
		
	tween = create_tween()
	tab_container.current_tab = page_number
	menu_audio.play()

	for i in range(page_dots.size()):
		var page_dot = page_dots[i]

		if (i == tab_container.current_tab):
			tween.parallel().tween_property(page_dot, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(page_dot, "offset_transform_scale", Vector2(0.5, 0.5), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			tween.parallel().tween_property(page_dot, "offset_transform_scale", Vector2(0.4, 0.4), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(page_dot, "modulate:a", 0.5, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _input(event: InputEvent) -> void:
	if (page_dots.is_empty() || !active):
		return

	var current_tab = tab_container.current_tab
	if (event.is_action_pressed("right_ui") || event.is_action_pressed("dialog_interact")):
		if (tab_container.current_tab >= max_pages-1):
			menu_audio.play()
			hide_tutorial()
			return
		else:
			current_tab += 1
			if (event.is_action_pressed("right_ui")):
				_animate_arrow(right_arrow)
			else:
				_animate_next_icon()

	elif (event.is_action_pressed("left_ui")):
		current_tab -= 1
		_animate_arrow(left_arrow)
	else:
		return

	change_page(current_tab)

func _animate_next_icon():
	const scale_target := 1.1
	const scale_ratio := 0.4
	var current_icon = gamepad_next_icon if Game.is_gamepad_mode else keyboard_next_icon

	var icon_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	icon_tween.tween_property(current_icon, "offset_transform_scale:x", scale_target, 0.2)
	icon_tween.parallel().tween_property(current_icon, "offset_transform_scale:y", scale_target, 0.35)
	icon_tween.parallel().tween_property(current_icon, "offset_transform_scale", Vector2(1.0, 1.0), 0.1).set_delay(0.35)
	icon_tween.parallel().tween_property(current_icon, "rotation_degrees", 2.0 * scale_ratio * [-1.0, 1.0].pick_random(), 0.1)
	icon_tween.parallel().tween_property(current_icon, "rotation_degrees", 0.0, 0.1).set_delay(0.1)

func _animate_arrow(arrow: TextureRect):
	const scale_target := 1.2
	const scale_ratio := 2.0

	var icon_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	icon_tween.tween_property(arrow, "offset_transform_scale:x", scale_target, 0.2)
	icon_tween.parallel().tween_property(arrow, "offset_transform_scale:y", scale_target, 0.35)
	icon_tween.parallel().tween_property(arrow, "offset_transform_scale", Vector2(1.0, 1.0), 0.1).set_delay(0.35)
	icon_tween.parallel().tween_property(arrow, "rotation_degrees", 2.0 * scale_ratio * [-1.0, 1.0].pick_random(), 0.1)
	icon_tween.parallel().tween_property(arrow, "rotation_degrees", 0.0, 0.1).set_delay(0.1)

func _format_control_icon():
	var push_icon: String = keyboard_push_icon

	if (Game.is_gamepad_mode):
		push_icon = gamepad_push_icon
		gamepad_next_icon.show()
		keyboard_next_icon.hide()
	else:
		gamepad_next_icon.hide()
		keyboard_next_icon.show()

	var formated_text = controls_original_text.format({
		"push": push_icon
	})

	controls_label.text = formated_text

func _process(_delta: float) -> void:
	if (active):
		Game.game_paused = true
		active = true
