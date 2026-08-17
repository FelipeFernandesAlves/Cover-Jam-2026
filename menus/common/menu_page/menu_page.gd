class_name MenuPage
extends Control

@export var page_name: String

@warning_ignore("unused_signal")
signal change_page(page_name: String)

@warning_ignore("unused_signal")
signal go_to_last_page()

@warning_ignore("unused_signal")
signal page_entered()

@warning_ignore("unused_signal")
signal page_exited()