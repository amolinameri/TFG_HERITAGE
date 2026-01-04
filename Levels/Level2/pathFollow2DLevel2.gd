extends PathFollow2D
var speed
var health
var goldReward
var damage
# we charge the scenes of all the mobs
@export var goblinScene: PackedScene
@export var slimesScene: PackedScene
@export var beeScene: PackedScene

var forcedType= "" # it would be use to force the spawn to choose a specific mob
var isSplit = false # for know if a slime is a child
var splitChildnumber = 2
var splitHealth = GameValues.slimeChildHealth # percentage of live of the slime childs
var isDying = false
var slownessSpike = 1
var slowTimeSpike = 0
var mobType = "goblin"
var mobInstance: Node2D = null
var paralizationCooldown = 0
var isHolding= false # if the bee is already making a paralization
var paralizedTower: Node2D = null
var lastparalizedTower: Node2D = null
var originalMobLocalPosition: Vector2 = Vector2.ZERO
var isDivided = false


func _ready() -> void:
	# we want the spawn of mobs to be randomize, so we use a math function
	randomize()
	# if we want to force a specific type, we make it possible
	if forcedType != "":
		mobType = forcedType
	# if we want to randomize, we use percentages of posibility to make them appear
	else:
		var randomNumber = randf()
		if randomNumber < 0.5:
			mobType = "goblin"
		elif randomNumber < 0.9:
			mobType = "slime"
		else:
			mobType = "bee"
	# depending on the result, it would spawn one or another type
	var chosenScene: PackedScene = goblinScene
	if mobType == "slime":
		chosenScene = slimesScene
	elif mobType == "bee":
		chosenScene = beeScene
	
	mobInstance= chosenScene.instantiate() as Node2D
	# this would be useful for the bee, that moves out of position to paralyze
	originalMobLocalPosition = mobInstance.position
	add_child(mobInstance)
	# if it is flyingMob, it would not get slowned from the spikes
	if mobType == "bee":
		mobInstance.add_to_group("flyingMob")
	else:
		mobInstance.add_to_group("groundMob")
	
	if mobType == "slime":
		speed      = GameValues.slimeSpeed
		health     = GameValues.slimeHealth
		if isSplit:
			health = GameValues.slimeHealth
		goldReward = GameValues.slimeReward
		damage     = GameValues.slimeDamage
	elif mobType == "bee":
		speed      = GameValues.beeSpeed
		health     = GameValues.beeHealth
		goldReward = GameValues.beeReward
		damage     = GameValues.beeDamage
	else:
		speed      = GameValues.goblinSpeed
		health     = GameValues.goblinHealth
		goldReward = GameValues.goblinReward
		damage     = GameValues.goblinDamage
	add_to_group("mobs")
# This would take actions depending on the situation of the mob

func _process(delta: float) -> void:
	if isDying:
		return
	var aux = 1  # = speed multiplier
	if slowTimeSpike > 0: # if the mob is already slowned...
		slowTimeSpike -= delta # we calculate how much time has
		aux = slownessSpike #
		if slowTimeSpike <= 0: # if 0, effect stop it, so mob start moving normal
			slownessSpike = 1 
			slowTimeSpike = 0
	
	var movementMultiplication = aux
	# how is programmed, the bee would always try to paralyze tower before moving
	if mobType == "bee" and not isHolding:
		var startedParalyzing = _try_paralize_tower(delta)
		if startedParalyzing:
			# if it start paralyzing, we stop his advance
			movementMultiplication = 0.0
			_put_bee_in_tower()  #and we make it be visually on the tower

	# if the bee is paralyzing...
	if mobType == "bee" and isHolding:
		# -and the tower told us is paralyze,
		if paralizedTower != null and paralizedTower._is_paralyze():
			# are used to mantain it on it
			movementMultiplication = 0.0
			_put_bee_in_tower()
		else:
			lastparalizedTower = paralizedTower
			# we make that the bee can not paralyze the same tower again
			paralizationCooldown = 0.5
			isHolding = false
			paralizedTower = null
			if mobInstance != null:
				# me return the bee to the same position
				mobInstance.position = originalMobLocalPosition

	# we make it move depending on  movementMultiplication
	progress += speed * movementMultiplication * delta # CHANGED

	# if his health arrives to 0, it would dissapear from the map
	if health <= 0 and not isDying:
		isDying = true
		call_deferred("_on_death")
		return

	# if he accomplish to arrive at the end, it would attack the player
	if progress_ratio >= 1.0:
		_attack_the_player()
		return
		
func _on_death() -> void:
	# if the mob is a slime is not split child
	if mobType == "slime" and not isSplit:
		# before we kill it, we make the animation of split into 2
		await _play_split_animation()
		# we make them spawn 
		var spawner = get_tree().current_scene.get_node_or_null("PathSpawner")
		# we make spawn the 2 child in the position of the father dead
		# with the amount of health and child slimes we decided
		if spawner:
			spawner._on_child_slimes_spawned(splitChildnumber)

			var childSlimeHealth = int(health * splitHealth)
			spawner._spawn_child(self.progress, childSlimeHealth, splitChildnumber)
		_mob_killed()
		queue_free()
		return

	_die()

func _play_death_animation() -> void:
	if mobInstance == null:
		return

	var playAnimation = true
	if mobType == "slime" and not isSplit: # IMPORTANTE: solo slimes divididos
		playAnimation = false

	if not playAnimation:
		return

	# while the animation is playing, it is already dead, so we need to stop
	# the collition logic
	var collision = mobInstance.find_child("CollisionShape2D") as CollisionShape2D
	if collision:
		collision.disabled = true
	# Same with the animation, we stop the waling animation and we initate death
	var walk = mobInstance.find_child("AnimatedSprite2D") as AnimatedSprite2D
	var death = mobInstance.find_child("AnimatedSprite2D2") as AnimatedSprite2D
	
	# stop looping animation
	death.sprite_frames.set_animation_loop("death", false)

	# Swap the animation to activate and deactivate
	if walk:
		walk.visible = false
	death.visible = true

	death.play("death")
	await death.animation_finished

# when a mob dies...
func _die() -> void:
	# means the player killed it, so it gets gold
	GameValues.gold += goldReward
	# we call the script of the spawner to remove it from the wave data
	_mob_killed()
	await _play_death_animation()
	# and also we elimitate from the map
	queue_free()

func _apply_slow() -> void:
	if mobType == "bee":
		return
	slownessSpike = GameValues.slowness
	slowTimeSpike = GameValues.slowTime

func _play_split_animation() -> void:
	if mobInstance == null:
		return

	var anim = mobInstance.find_child("AnimatedSprite2D") as AnimatedSprite2D
	anim.sprite_frames.set_animation_loop("split", false)
	anim.play("split")
	await anim.animation_finished


func _attack_the_player() -> void:
	# if we get to 0 health point, is game over
	if (GameValues.playerHealth - damage) <= 0:
		# Game over means call the function of lose from the UI
		GameValues.playerHealth = 0 # for visual purposes, noting more
		var ui = get_tree().current_scene.get_node_or_null("UI")
		ui._show_defeat()
	else:
		# if do not reach 0 HP, then we rest the damage and the game continues
		GameValues.playerHealth -= damage
	_mob_killed()
	queue_free()

# we call the script of the spawner to remove the mob from the wave data
func _mob_killed() -> void:
	var spawner = get_tree().current_scene.get_node_or_null("PathSpawner")
	if spawner:
		spawner._on_dead_mob()
		
func _try_paralize_tower(delta: float) -> bool:
	# we see if the bee can paralyze
	if isHolding:
		return false
	# if not, we see if has already end his cooldown
	paralizationCooldown -= delta
	if paralizationCooldown > 0.0:
		return false
	
	#radius means how closer need to be on a tower to paralyze it
	var radius = GameValues.beeParalizationRadius
	
	# we would pick the closest
	var best: Node2D = null


	for towers in get_tree().get_nodes_in_group("towerArcher"):
		# we see all the tower of archers
		var tower = towers as Node2D
		if tower == null:
			continue
		# if the closes is the one has already paralyze, we ignore it
		if tower == lastparalizedTower:
			continue
		var distance = global_position.distance_to(tower.global_position)
		# if the tower is in the actuation radius we selected as the best
		if distance <= radius:
			best = tower # we save the best candidate


	if best == null:
		return false
	#
	var spawner = get_tree().current_scene.get_node_or_null("PathSpawner")
	# we paralyze the tower
	if spawner:
		if spawner._try_paralize_tower(best):
			isHolding = true
			paralizedTower = best
			return true
	return false
				
				
func _put_bee_in_tower() -> void:
	if paralizedTower == null or not is_instance_valid(paralizedTower):
		return

	# we put the Bee in front of the tower in the map, for visual purposes
	if mobInstance is CanvasItem:
		mobInstance.z_as_relative = false
		mobInstance.z_index = 1000

	# we move the bee visually a little bit more up
	mobInstance.global_position = paralizedTower.global_position + Vector2(0, -20)
