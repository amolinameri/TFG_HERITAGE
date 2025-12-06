extends PathFollow2D
var speed
var health
var goldReward
var damage

# For now, we only have 1 enemy. This would change.
#when the enemy appears, it would get his data charged
func _ready() -> void:
	speed       = GameValues.goblinSpeed
	health      = GameValues.goblinHealth
	goldReward = GameValues.goblinReward
	damage      = GameValues.goblinDamage

# This would take actions depending on the situation of the enemy
func _process(delta: float) -> void:
	# we calculate his progress
	progress += speed * delta

	# if his health arrives to 0, it would dissapear from the map
	if health <= 0:
		_die()
		return

	# if he accomplish to arrive at the end, it would attack the player
	if progress_ratio >= 1.0:
		_attack_the_player()
		return

# when a mob dies...
func _die() -> void:
	# means the player killed it, so it gets gold
	GameValues.gold += goldReward
	# we call the script of the spawner to remove it from the wave data
	_spawner_enemy_killed_dead()
	# and also we elimitate from the map
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
		
	_spawner_enemy_killed_dead()
	queue_free()

# we call the script of the spawner to remove the mob from the wave data
func _spawner_enemy_killed_dead() -> void:
	var spawner = get_tree().current_scene.get_node_or_null("PathSpawner")
	if spawner:
		spawner._on_dead_enemy()
