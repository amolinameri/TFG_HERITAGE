extends Node2D

var pathScene: PackedScene = preload("res://Levels/Level2/Level2.tscn")

# array with mobs per wave
var mobsWave = GameValues.leveTwoAmount

# interval of time from mob to mob
var spawnInterval = GameValues.levelTwoInterval

# states of the wave
var currentWave
var mobsSpawned
var mobsAlive
var mobsRemaining

var isSpawning = false # for know if are mobs spawning or not
# timer of appearances 
@onready var timer: Timer = $Timer
# ui, the label that shows the data of the wave to the player
@onready var waveLabel: Label = $"../UI/Wave"
var baseHealthGoblin
var healthWaveGoblin = 15
var healthWaveslime = 10
var healthWavesBee = 15
var baseHealthSlime
var baseHealthBee
var beeParalizationActive
var paralizedTowersThisWave = {}

func _ready() -> void:
	baseHealthGoblin = GameValues.goblinHealth
	baseHealthSlime = GameValues.slimeHealth
	baseHealthBee= GameValues.beeHealth
	_start_wave(0)
	
#it would increment the health of the mobs every wave
func _calculate_health_wave(healthExtra: int, baseHealth: int)-> int:
	return currentWave * healthExtra + baseHealth

func _start_wave(waveIndex: int) -> void:
	# Fixed bug, if it wast the last wave, and the player still has 1 live
	# show victory, else, GAME OVER.
	if waveIndex >= mobsWave.size():
		isSpawning = false
		timer.stop()
		if GameValues.playerHealth > 0:
			var ui = get_tree().current_scene.get_node_or_null("UI")
			if ui:
				ui._show_victory()
		return
	# if it is the first wave, we give some preparation time
	timer.wait_time = spawnInterval
	if waveIndex == 0:
		waveLabel.text = "¡preparate!"
		await get_tree().create_timer(10).timeout
	timer.start()
	
	# we see if there is a next wave
	# if not...
	beeParalizationActive = 0
	if waveIndex >= mobsWave.size():
		isSpawning = false # no more spawning
		timer.stop() # we stop the timer to stop calling the spawn
		# we call the UI to call the function with the victory message
		var ui = get_tree().current_scene.get_node("UI")
		ui._show_victory()
		return
		
	# if there is a next one, we prepare all the data
	currentWave = waveIndex
	mobsSpawned = 0
	mobsAlive = 0
	mobsRemaining = mobsWave[currentWave] 
	isSpawning = true
	
	GameValues.goblinHealth = _calculate_health_wave(healthWaveGoblin, baseHealthGoblin)
	GameValues.slimeHealth = _calculate_health_wave(healthWaveslime, baseHealthSlime)
	GameValues.beeHealth = _calculate_health_wave(healthWavesBee, baseHealthBee)
	# every X seconds, a new mob needs to appear
	timer.wait_time = spawnInterval
	timer.start()
	# we update the label that appears in the UI
	_update_wave_text()


func _on_timer_timeout() -> void:
	# if we have spawn all the mobs, we return
	if not isSpawning:
		return

	# else, me start spawning mobs and updating the information of the counters
	_spawn_mob()
	mobsSpawned += 1
	mobsAlive += 1
	_update_wave_text()

	# if that was the last mob...
	if mobsSpawned >= mobsWave[currentWave]:
		# we stop spawning and 
		isSpawning = false
		# if we do not need more mobs for the wave, then stop the timer
		timer.stop()
		

func _spawn_mob() -> void:
	var auxPath = pathScene.instantiate()
	add_child(auxPath)


func _on_dead_mob() -> void:
	# when the mob dies (or arrives at the end)
	mobsAlive -= 1
	mobsRemaining -= 1
	# to make sure that, if 2 mobs dies at the same time, it get to 0 only                 
	if mobsRemaining < 0:
		mobsRemaining = 0
	_update_wave_text()

	# if there are not more mobs in the map, and we are not going to spawn
	# more, means that the wave has ended, so we start a next one
	if mobsAlive == 0 and not isSpawning:
		_start_wave(currentWave+ 1)

#slimes at the first death, spawn 2 more slimes, so we need it to count them
func _on_child_slimes_spawned(count: int) -> void:
	mobsAlive += count 
	mobsRemaining += count
	_update_wave_text()

func _update_wave_text() -> void:
	waveLabel.text = "Oleada:%d/%d Enem.: %d" % [
		currentWave+ 1,
		mobsWave.size(),
		mobsRemaining
	]

#slimes slipt in 2 in the first death
func _spawn_child(progress: float, childSlime: int, childs: int) -> void:
	for i in range(childs):
		var auxPath = pathScene.instantiate()
		# now we force the game to...
		var path: PathFollow2D = auxPath.get_node("PathFollow2D") as PathFollow2D
		path.forcedType = "slime" # spawn slime type of mobs
		path.isSplit = true #it is split, so it would not split again
		path.health = childSlime #we put the health for the childSlime
		 # we separate the two child to not make it be on amount the other
		path.progress = progress - (i * 30)
		add_child(auxPath)
		
func _try_paralize_tower(tower: Node) -> bool:
	if tower == null:
		return false

	# if the tower has already the status, we skip it
	if tower.has_method("_is_paralyze") and tower._is_paralyze():
		return false

	# the bees, per wave, can only paralize tower a certain amount of times
	if beeParalizationActive >= GameValues.beeParalizationLimit:
		return false

	# we make sure the tower is paralize after we call the function
	var applied = false
	if tower.has_method("_apply_paralization"):
		applied = tower._apply_paralization(GameValues.beeParalizationDuration)

	if applied:
		beeParalizationActive += 1
	return applied
