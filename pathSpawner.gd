extends Node2D

var pathScene: PackedScene = preload("res://Level1.tscn")

# array with enemies per wave
var enemiesWave = GameValues.levelOneAmount

# interval of time from mob to mob
var spawnInterval = GameValues.levelOneInterval

# states of the wave
var currentWave
var enemiesSpawned
var enemiesAlive
var enemiesRemaining

var isSpawning = false # for know if are enemies spawning or not
# timer of appearances 
@onready var timer: Timer = $Timer
# ui, the label that shows the data of the wave to the player
@onready var waveLabel: Label = $"../UI/Wave"
var baseHealthGoblin
var healthWaveGoblin = 15

func _ready() -> void:
	baseHealthGoblin = GameValues.goblinHealth
	_start_wave(0)
	
#it would increment the health of the enemies every wave
func _calculate_health_wave(healthExtra: int)-> int:
	return currentWave * healthExtra + baseHealthGoblin

func _start_wave(waveIndex: int) -> void:
	# we see if there is a next wave
	# if not...
	if waveIndex >= enemiesWave.size():
		isSpawning = false # no more spawning
		timer.stop() # we stop the timer to stop calling the spawn
		# we call the UI to call the function with the victory message
		var ui = get_tree().current_scene.get_node("UI")
		ui._show_victory()
		return
		
	# if there is a next one, we prepare all the data
	currentWave = waveIndex
	enemiesSpawned = 0
	enemiesAlive = 0
	enemiesRemaining = enemiesWave[currentWave] 
	isSpawning = true
	
	GameValues.goblinHealth = _calculate_health_wave(healthWaveGoblin)
	# every X seconds, a new enemy needs to appear
	timer.wait_time = spawnInterval
	timer.start()
	# we update the label that appears in the UI
	_update_wave_label_text()


func _on_timer_timeout() -> void:
	# if we have spawn all the enemies, we return
	if not isSpawning:
		return

	# else, me start spawning enemies and updating the information of the counters
	_spawn_enemy()
	enemiesSpawned += 1
	enemiesAlive += 1
	_update_wave_label_text()

	# if that was the last enemy...
	if enemiesSpawned >= enemiesWave[currentWave]:
		# we stop spawning and 
		isSpawning = false
		# if we do not need more enemies for the wave, then stop the timer
		timer.stop()
		

func _spawn_enemy() -> void:
	var auxPath = pathScene.instantiate()
	add_child(auxPath)


func _on_dead_enemy() -> void:
	# when the enemy dies (or arrives at the end)
	enemiesAlive -= 1
	enemiesRemaining -= 1
	# to make sure that, if 2 enemies dies at the same time, it get to 0 only                 
	if enemiesRemaining < 0:
		enemiesRemaining = 0
	_update_wave_label_text()

	# if there are not more enemies in the map, and we are not going to spawn
	# more, means that the wave has ended, so we start a next one
	if enemiesAlive == 0 and not isSpawning:
		_start_wave(currentWave+ 1)


func _update_wave_label_text() -> void:
	waveLabel.text = "Oleada %d de %d - Enemigos: %d" % [
		currentWave+ 1,
		enemiesWave.size(),
		enemiesRemaining
	]
