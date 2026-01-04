extends Node
class_name settings

const SETTINGSPATH = "user://settingsHeritage.cfg"

var volume
var fullscreen

func _ready() -> void:
	_load_settings()
	_apply_audio()
	_apply_video()

func _load_settings() -> void:
	var configurationFile = ConfigFile.new()
	
	fullscreen = bool(configurationFile.get_value("video", "fullscreen", false))
	volume = float(configurationFile.get_value("audio", "volume", 50))
	

func _save_settings() -> void:
	var configurationFile = ConfigFile.new()
	configurationFile.set_value("video", "fullscreen", fullscreen)
	configurationFile.set_value("audio", "volume", volume)
	configurationFile.save(SETTINGSPATH)

func _apply_audio() -> void:
	var index = AudioServer.get_bus_index("Master")

	# we make sure the bar at 0 means absolute silence
	if volume <= 0.0:
		AudioServer.set_bus_mute(index, true)
		return

	# if it is not in 0, we make it from 0 to 1 to use them as db
	AudioServer.set_bus_mute(index, false)
	var linear = volume / 100.0
	AudioServer.set_bus_volume_db(index, linear_to_db(linear))

func _apply_video() -> void:
	# if the player select the option fullscren, it changes resolution
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
