extends CanvasLayer
@onready var endPanel: ColorRect = $EndPanel
@onready var endText: Label = $EndPanel/EndText

# how much time from the endPanel appears to change to the main menu scene
const RETURNDELAY = 3

# until we call it, the endPanel that shows at the end of the level is invisible
func _ready() -> void:
	endPanel.visible = false

# if the player wins, we get visible the panel with the winner text
func _show_victory() -> void:
	endPanel.visible = true
	endText.text = "ALPHA COMPLETADA!"
	#and we pause all of the logic, to not make it run on the background
	get_tree().paused = true
	_end_game()

# if the player lose, we get visible the panel with the winner text
func _show_defeat() -> void:
	endPanel.visible = true
	endText.text = "GAME OVER"
	# and we pause all of the logic, to not make it run on the background
	get_tree().paused = true
	_end_game()
func _end_game() -> void:
	# we set a timer to return to the main menu, and we wait.
	await get_tree().create_timer(RETURNDELAY).timeout
	# because we want the logic of the game running again, we unpaused
	get_tree().paused = false
	# me return to the main scene
	get_tree().change_scene_to_file("res://mainMenu.tscn")
