extends MenuPage

@export var back_button: Button

func _on_back_pressed() -> void:
	go_to_last_page.emit()
