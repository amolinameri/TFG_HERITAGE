extends Node

# global variables
var gold: int
var playerHealth: int
var goblinHealth
var goblinSpeed
var goblinDamage
var goblinReward 
var arrowTowerDamage
var arrowTowerCost
var arrowSpeed
var arrowReloadTime
var levelOneInterval
var levelOneAmount

# in data we would save all the data from the JSON
var gameData: Dictionary = {}

func _ready():
	_load_data()
	_reset_all_stats()

func _load_data():
	var file = FileAccess.open("res://Parameters/gameValues.json", FileAccess.READ)
	if file:
		var jsonText = file.get_as_text()
		var json = JSON.new()
		var notError = json.parse(jsonText)
		
		if notError == OK:
			gameData = json.data


# from here it resets the values we acces from global
func _reset_all_stats():
	gold = gameData["player"]["gold"]
	playerHealth = gameData["player"]["playerHealth"]
	goblinHealth = gameData["enemies"]["goblin"]["health"]
	goblinDamage = gameData["enemies"]["goblin"]["damage"]
	goblinSpeed = gameData["enemies"]["goblin"]["speed"]
	goblinReward = gameData["enemies"]["goblin"]["reward"]
	arrowTowerDamage = gameData["towers"]["archers"]["damage"]
	arrowSpeed = gameData["towers"]["archers"]["speed"]
	arrowReloadTime = gameData["towers"]["archers"]["reloadTime"]
	arrowTowerCost = gameData["towers"]["archers"]["cost"]
	levelOneInterval = gameData["levels"]["level1"]["spawnInterval"]
	levelOneAmount= gameData["levels"]["level1"]["waves"]
