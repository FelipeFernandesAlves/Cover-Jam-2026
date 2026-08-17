extends Node

var music_volume: float = 100.0: set = _set_music_volume
var sfx_volume: float = 100.0: set = _set_sfx_volume

func _set_music_volume(new_value: float):
	music_volume = new_value
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(music_volume/100))

func _set_sfx_volume(new_value):
	sfx_volume = new_value
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(sfx_volume/100))

func save_config():
	pass

func load_config():
	pass