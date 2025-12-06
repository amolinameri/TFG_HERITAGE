extends Node2D

@onready var anim: AnimatedSprite2D = $ArrowTowerSprite
@onready var area: Area2D           = $TowerArea #areaOfdetection
@onready var arrowsContainer: Node = $ArrowsContainer #the arrows will go here
@onready var shootPlace: Node2D    = $AreaAim #from where it would appear the arrows
@export var fireRate = GameValues.arrowReloadTime
var timeOcurredSinceShoot = 0.0

var arrow: PackedScene = preload("res://Towers/arrow.tscn")

var targets = [] # enemies in the area of the tower would get inside
var actualTarget: Node2D = null


func _ready() -> void:
	anim.play("arrowTower")


func _process(delta: float) -> void: 
	timeOcurredSinceShoot += delta #Timer for shooting
	_clean_targets()
	if actualTarget == null:
		_select_target()
	#If we have a selected enemy, and the time since the last shoot is atleast
	# the same value as de fireRate of the tower...
	if actualTarget != null and timeOcurredSinceShoot >= fireRate:
		_shoot()  # We shoot the arrow
		timeOcurredSinceShoot = 0.0 # Timer starts again


func _clean_targets() -> void:
	# We filter the actual targets to detach the enemies we can not attack
	# if we dont have any target, we do not need to clean
	if actualTarget == null:
		return
		
	targets = targets.filter(func(enemies):
		# The filters to be still inside the targets of the tower are: 
		# -They still exist
		# -they have not get to the end of the lane
		return enemies != null and enemies.is_inside_tree()
	)


func _select_target() -> void:
	# Is there is nothing in range, we skip the funcion to avoid errores
	if targets.is_empty():
		actualTarget = null
		return

	# For now, the target would be the first we encounter
	var choosedEnemy: Node2D = targets[0]
	# The progress of the target in the path (1 = 100%, 0 = 0%)
	var choosedProgress = 0.0

	for enemy in targets:
		# Because the parent of the enemy would be always the path...
		var pathIsParent = enemy.get_parent()
		#... we can know the progress of the path in that enemy
		var possibleEnemyProgress = pathIsParent.progress_ratio
		
		# So we iterate for all the possible target, and we would get the one
		# That is more advanced in the path as our criteria to choose target
		if possibleEnemyProgress > choosedProgress:
				choosedProgress = possibleEnemyProgress
				choosedEnemy = enemy
	actualTarget = choosedEnemy


func _shoot() -> void:
	# It would not shoot if actualTarget have been already killed or
	# actualTarget has yet to assigned a new enemy
	if actualTarget == null or not is_instance_valid(actualTarget):
		actualTarget = null
		return

	# If we are going to shoot, we create the arrow we are gonna use
	var arrowInstance: CharacterBody2D = arrow.instantiate()
	arrowsContainer.add_child(arrowInstance)
	#we put the arrow in position we dessignated as the started place
	arrowInstance.global_position = shootPlace.global_position
	#the target of the arrow would be the one selected in the previous function
	arrowInstance.target = actualTarget


func _on_tower_area_body_entered(body: Node2D) -> void:
	# We would add as targets of the tower every enemy that enters the range
	if "Goblin" in body.name: # we would add more enemies in the future
		if body not in targets:
			targets.append(body)


func _on_tower_area_body_exited(body: Node2D) -> void:
	# If an emey exits the area of action, we elimitate it from the targets
	# and if is the actual target, too
	if body in targets:
		targets.erase(body)
	if body == actualTarget:
		actualTarget = null
