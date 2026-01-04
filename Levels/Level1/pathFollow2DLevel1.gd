extends PathFollow2D
@onready var walk: AnimatedSprite2D = $Goblin/AnimatedSprite2D

var speed
var health
var goldReward
var damage
var dies = false
var slownessSpike = 1
var slowTimeSpike = 0
@onready var death: AnimatedSprite2D = $Goblin/AnimatedSprite2D2
@onready var collision: CollisionShape2D = $Goblin/CollisionShape2D

# For now, we only have 1 mob. This would change.
#when the mob appears, it would get his data charged
func _ready() -> void:
	speed       = GameValues.goblinSpeed
	health      = GameValues.goblinHealth
	goldReward = GameValues.goblinReward
	damage      = GameValues.goblinDamage
	add_to_group("mobs")

# This would take actions depending on the situation of the mob
func _process(delta: float) -> void:
	
	var aux = 1  # = speed multiplier
	if slowTimeSpike > 0: # if the mob is already slowned...
		slowTimeSpike -= delta # we calculate how much time has
		aux = slownessSpike #
		if slowTimeSpike <= 0: # if 0, effect stop it, so mob start moving normal
			slownessSpike = 1 
			slowTimeSpike = 0
	# we calculate his progress
	progress += speed * delta * aux

	# if his health arrives to 0, it would dissapear from the map
	if health <= 0:
		_die()
		return

	# if he accomplish to arrive at the end, it would attack the player
	if progress_ratio >= 1:
		_attack_the_player()
		return

# when a mob dies...
func _die() -> void:
	if dies:
		return
	dies = true

	# means the player killed it, so it gets gold
	GameValues.gold += goldReward
	# we call the script of the spawner to remove it from the wave data
	_mob_killed()
	
	#Because we want the animation of death, we eliminate him from collisions
	speed = 0
	if collision:
		collision.disabled = true

	# And we change his sprite of death, after that....
	if walk:
		walk.visible = false

	if death:
		death.visible = true
		death.play("death")
		await death.animation_finished
	
	# ...also we elimitate from the map
	queue_free()


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

func _apply_slow() -> void:
	slownessSpike = GameValues.slowness # we assigned from the JSON de % of slowness
	# this is only for make the slowness effect not we shortened from other spike
	slowTimeSpike = max(slowTimeSpike, GameValues.slowTime)
