class_name MenuPageBox
extends Control

@export var first_page: MenuPage
var active: bool = true:
	set(value):
		active = value
		if (!active && current_page):
			current_page.hide()
			current_page.page_exited.emit()
			current_page.change_page.disconnect(_on_change_page)
			current_page.go_to_last_page.disconnect(_on_go_to_last_page)
			remove_child(current_page)
			last_page = null
			current_page = null


var pages: Dictionary[String, MenuPage] = {}
var current_page: MenuPage = null
var last_page: MenuPage = null

func _ready() -> void:
	for child in get_children():
		child.hide()
		if (child is MenuPage && child.page_name):
			pages[child.page_name] = child
			remove_child(child)
	
	if (first_page):
		change_page(first_page.page_name)
	elif (pages.size() > 0):
		change_page(pages.get(pages.keys()[0]))

func change_page(page_name: String):
	var new_page: MenuPage = pages.get(page_name)
	if (!new_page):
		return

	if (current_page):
		current_page.hide()
		current_page.page_exited.emit()
		current_page.change_page.disconnect(_on_change_page)
		current_page.go_to_last_page.disconnect(_on_go_to_last_page)
		last_page = current_page
		remove_child(current_page)

	add_child(new_page)
	new_page.page_entered.emit()
	new_page.change_page.connect(_on_change_page)
	new_page.go_to_last_page.connect(_on_go_to_last_page)
	new_page.show()

	current_page = new_page

func go_to_last_page():
	if (!last_page || !last_page.page_name):
		return

	change_page(last_page.page_name)
	
func _on_change_page(page_name: String):
	change_page(page_name)

func _on_go_to_last_page():
	go_to_last_page()
