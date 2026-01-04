extends CharacterBody2D

var fireballDamage = GameValues.mageTowerDamage
var speedProjectile = GameValues.mageProjectileSpeed
var target: Node2D = null  #The actual target of the arrow
var splashRange= GameValues.mageSplashRange # splash range

func _physics_process(delta: float) -> void:
	# If the target ceases to exist, we eliminate the fireball to avoid bugs
	if target == null or not is_instance_valid(target) or target.is_queued_for_deletion():
		queue_free()
		return
	# If exists, we get the position of the target
	var targetPosition: Vector2 = target.global_position
	
	# added for a bug, we ensure is dissapeared when is close enough
	var targetBug: Vector2 = targetPosition - global_position
	if targetBug.length_squared() < 10:
		queue_free()
		return
	
	velocity = global_position.direction_to(targetPosition) * speedProjectile
	look_at(targetPosition) # the fireball needs to point to the mob
	move_and_slide()

# When the fireball makes contact with the mob, it reduces his health points
# Using his value of damage and then disappear from the map
func _on_area_2d_body_entered(body: Node2D) -> void:
	var mob = body.get_parent()
	if mob == null or not ("health" in mob):
		return
	#for the splash, we also need to know where the fireball explode,
	# as thats the center point were the radious of explosion is calculated
	var explosionCenter: Vector2 = body.global_position
	_apply_splash_damage(mob, explosionCenter)
	queue_free()
	
func _apply_splash_damage(principalMob: Node2D, centerExplosion: Vector2) -> void:
	
	if principalMob != null and ("health" in principalMob):
		principalMob.health -= fireballDamage
		
	#we get all the mobs, if there is only one, we just rest from his health
	var mobs = get_tree().get_nodes_in_group("mobs")
	if mobs.is_empty():
		principalMob.health -= fireballDamage
		return
	# if there are more than one, we examinate if there is someone in range
	for mob in mobs:
		#if there is atleast one, we also take health from him
		if mob.global_position.distance_to(centerExplosion) <= splashRange:
			mob.health -= fireballDamage
