class_name PauseMenu
extends Control

@export var continue_button: Button
@export var page_box: MenuPageBox
@export var main_page: MenuPage
@export var main_page_button_box: ButtonBox

func _ready() -> void:
	main_page.page_entered.connect(func (): 
		main_page_button_box.reset_focus()
		)

func _on_continue_pressed() -> void:
	change_visibility(false)
	get_tree().paused = false

func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/main/MainMenu.tscn")

func change_visibility(visibility: bool):
	visible = visibility
	if (!visibility):
		page_box.active = false
	else:
		page_box.change_page("main")

func _on_controls_pressed() -> void:
	page_box.change_page("controls")

func _on_config_pressed() -> void:
	page_box.change_page("config")