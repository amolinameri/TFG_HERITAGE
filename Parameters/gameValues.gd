extends Node

# global variables
var gold: int
var playerHealth: int
var goblinHealth
var goblinSpeed
var goblinDamage
var goblinReward
var slimeHealth
var slimeChildHealth
var slimeSpeed
var slimeDamage
var slimeReward 
var arrowTowerDamage
var arrowTowerCost
var arrowSpeedProjectile
var arrowReloadTime
var mageTowerDamage
var mageTowerCost
var mageProjectileSpeed
var mageSplashRange
var mageReloadTime
var levelOneInterval
var levelOneAmount
var levelTwoInterval
var leveTwoAmount
var spikeCost
var spikeDamage
var spikeUses
var slowness
var slowTime

var beeHealth
var beeSpeed
var beeDamage
var beeReward
var beeParalizationDuration
var beeParalizationLimit
var beeParalizationRadius
var beeParalizationTarget
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
	
	goblinHealth = gameData["mobs"]["goblin"]["health"]
	goblinDamage = gameData["mobs"]["goblin"]["damage"]
	goblinSpeed = gameData["mobs"]["goblin"]["speed"]
	goblinReward = gameData["mobs"]["goblin"]["reward"]
	
	slimeHealth = gameData["mobs"]["slime"]["health"]
	slimeChildHealth=  gameData["mobs"]["slime"]["healthChild"]
	slimeDamage = gameData["mobs"]["slime"]["damage"]
	slimeSpeed = gameData["mobs"]["slime"]["speed"]
	slimeReward = gameData["mobs"]["slime"]["reward"]
	
	arrowTowerDamage = gameData["towers"]["archers"]["damage"]
	arrowSpeedProjectile = gameData["towers"]["archers"]["speedProjectile"]
	arrowReloadTime = gameData["towers"]["archers"]["reloadTime"]
	arrowTowerCost = gameData["towers"]["archers"]["cost"]
	
	mageTowerDamage = gameData["towers"]["mages"]["damage"]
	mageProjectileSpeed = gameData["towers"]["mages"]["speedProjectile"]
	mageReloadTime = gameData["towers"]["mages"]["reloadTime"]
	mageSplashRange = gameData["towers"]["mages"]["splashRange"]
	mageTowerCost = gameData["towers"]["mages"]["cost"]
	
	spikeCost = gameData["towers"]["spike"]["cost"]
	spikeDamage = gameData["towers"]["spike"]["damage"]
	spikeUses = gameData["towers"]["spike"]["uses"]
	slowness = gameData["towers"]["spike"]["slowness"]
	slowTime = gameData["towers"]["spike"]["slowTime"]
	
	levelOneInterval = gameData["levels"]["level1"]["spawnInterval"]
	levelOneAmount= gameData["levels"]["level1"]["waves"]
	
	levelTwoInterval= gameData["levels"]["level2"]["spawnInterval"]
	leveTwoAmount = gameData["levels"]["level2"]["waves"]
	beeHealth = gameData["mobs"]["bee"]["health"]
	
	beeSpeed  = gameData["mobs"]["bee"]["speed"]
	beeDamage = gameData["mobs"]["bee"]["damage"]
	beeReward = gameData["mobs"]["bee"]["reward"]

	beeParalizationDuration      = gameData["mobs"]["bee"]["paralizationDuration"]
	beeParalizationLimit  = gameData["mobs"]["bee"]["paralizationLimit"]
	beeParalizationRadius        = gameData["mobs"]["bee"]["paralizationRadius"]
	beeParalizationTarget        = gameData["mobs"]["bee"]["paralizationTarget"]
