extends Node

const MENU: AudioStream = preload("res://Music/mainMenu.wav")
const LEVEL: AudioStream = preload("res://Music/levelsMusic.wav")

@onready var player: AudioStreamPlayer = AudioStreamPlayer.new()
var music: AudioStream = null

func _ready() -> void:
	add_child(player)
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.bus = "MusicPlayer"

func _play_music_menu() -> void:
	_play_music(MENU)

func _play_music_level() -> void:
	_play_music(LEVEL)

func _play_music(streamNew: AudioStream) -> void:
	if streamNew == music and player.playing:
		return
	
	music = streamNew
	player.stream = music
	player.play()
