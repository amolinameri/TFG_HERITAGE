extends Node2D

@onready var anim: AnimatedSprite2D = $MageTowerSprite
@onready var area: Area2D           = $TowerArea #areaOfdetection
@onready var fireballsContainer: Node = $FireballsContainer #the meteorites will go here
@onready var shootPlace: Node2D    = $AreaAim #from where it would appear the meteorites
var fireRate = GameValues.mageReloadTime
var timeOcurredSinceShoot = 0.0

var fireball: PackedScene = preload("res://Defense/mageTower/fireball.tscn")

var targets = [] # mobs in the area of the tower would get inside
var actualTarget: Node2D = null


func _ready() -> void:
	anim.play("default")


func _process(delta: float) -> void: 
	timeOcurredSinceShoot += delta #Timer for shooting
	_clean_targets()
	if actualTarget == null:
		_select_target()
	#If we have a selected mob, and the time since the last shoot is atleast
	# the same value as de fireRate of the tower...
	if actualTarget != null and timeOcurredSinceShoot >= fireRate:
		_shoot()  # We shoot the arrow
		timeOcurredSinceShoot = 0.0 # Timer starts again


func _clean_targets() -> void:
	# We filter the actual targets to detach the mobs we can not attack
	# if we dont have any target, we do not need to clean
	if actualTarget == null:
		return
		
	targets = targets.filter(func(mobs):
		# The filters to be still inside the targets of the tower are: 
		# -They still exist
		# -they have not get to the end of the lane
		return mobs != null and mobs.is_inside_tree()
	)


func _select_target() -> void:
	# Is there is nothing in range, we skip the funcion to avoid errors
	if targets.is_empty():
		actualTarget = null
		return

	# For now, the target would be the first we encounter
	var choosedMob: Node2D = targets[0]
	# The progress of the target in the path (1 = 100%, 0 = 0%)
	var choosedProgress = 0.0

	for mob in targets:
		# Because the parent of the mob would be always the path...
		var pathIsParent = mob.get_parent()
		#... we can know the progress of the path in that mob
		var possibleMobProgress = pathIsParent.progress_ratio
		
		# So we iterate for all the possible target, and we would get the one
		# That is more advanced in the path as our criteria to choose target
		if possibleMobProgress > choosedProgress:
				choosedProgress = possibleMobProgress
				choosedMob = mob
	actualTarget = choosedMob


func _shoot() -> void:
	# It would not shoot if actualTarget have been already killed or
	# actualTarget has yet to assigned a new mob
	if actualTarget == null or not is_instance_valid(actualTarget):
		actualTarget = null
		return

	# If we are going to shoot, we create the arrow we are gonna use
	var fireballInstance: CharacterBody2D = fireball.instantiate()
	fireballsContainer.add_child(fireballInstance)
	#we put the arrow in position we dessignated as the started place
	fireballInstance.global_position = shootPlace.global_position
	#the target of the arrow would be the one selected in the previous function
	fireballInstance.target = actualTarget


func _on_tower_area_body_entered(body: Node2D) -> void:
	# We would add as targets of the tower every mob that enters the range
	if ("Goblin" in body.name) || ("Slime" in body.name) || ("Bee" in body.name):
		if body not in targets:
			targets.append(body)


func _on_tower_area_body_exited(body: Node2D) -> void:
	# If an emey exits the area of action, we elimitate it from the targets
	# and if is the actual target, too
	if body in targets:
		targets.erase(body)
	if body == actualTarget:
		actualTarget = null
