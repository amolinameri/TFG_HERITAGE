extends Node2D

@onready var anim: AnimatedSprite2D = $ArrowTowerSprite
@onready var area: Area2D           = $TowerArea #areaOfdetection
@onready var arrowsContainer: Node = $ArrowsContainer #the arrows will go here
@onready var shootPlace: Node2D    = $AreaAim #from where it would appear the arrows
var fireRate = GameValues.arrowReloadTime
var timeOcurredSinceShoot = 0

var arrow: PackedScene = preload("res://Defense/arrowTower/arrow.tscn")

var targets = [] # mobs in the area of the tower would get inside
var actualTarget: Node2D = null
var paralyzeTime = 0 # how many seconds the tower would be paralyze

func _ready() -> void:
	anim.play("default")
	
	# if the tower is not yet put on the map, we ignore it
	if name != "copyTower" and process_mode != Node.PROCESS_MODE_DISABLED:
		# else, me put it on the group the bees would use to kwow valid targets
		add_to_group("towerArcher")
	
func _apply_paralization(duration: float) -> bool:
	# it would only paralyze the tower if there is not already a bee on it
	if paralyzeTime > 0:
		return false
	paralyzeTime = duration
	return true

# boolean to let know if the tower is already been afected for now
func _is_paralyze() -> bool:
	return paralyzeTime > 0
	
func _process(delta: float) -> void:
	# a paralyze tower can not shoot
	if paralyzeTime > 0:
		paralyzeTime -= delta
		# while is paralyze, it would turn on grey colors
		modulate = Color(0.6627451, 0.6627451, 0.6627451, 1)
		return
	else:
		# if the paralization ended, we turn the colors back to normal
		modulate = Color(1, 1, 1, 1)
		
	timeOcurredSinceShoot += delta # Timer for shooting
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
	var choosedProgress = 0

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
	var arrowInstance: CharacterBody2D = arrow.instantiate()
	arrowsContainer.add_child(arrowInstance)
	#we put the arrow in position we dessignated as the started place
	arrowInstance.global_position = shootPlace.global_position
	#the target of the arrow would be the one selected in the previous function
	arrowInstance.target = actualTarget


func _on_tower_area_body_entered(body: Node2D) -> void:
	# We would add as targets of the tower every mob that enters his range
	if ("Goblin" in body.name) or ("Slime" in body.name) or ("Bee" in body.name):
		if body not in targets:
			targets.append(body)


func _on_tower_area_body_exited(body: Node2D) -> void:
	# If an emey exits the area of action, we elimitate it from the targets
	# and if is the actual target, too
	if body in targets:
		targets.erase(body)
	if body == actualTarget:
		actualTarget = null
