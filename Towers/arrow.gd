extends CharacterBody2D

var bulletDamage = GameValues.arrowTowerDamage
var speed = GameValues.arrowSpeed
var target: Node2D = null  #The actual target of the arrow


func _physics_process(delta: float) -> void:
	# If the target ceases to exist, we eliminate the arrow to avoid bugs
	if target == null or not target.is_inside_tree():
		queue_free()
		return
	# If exists, we get the position of the target
	var targetPosition: Vector2i = target.global_position
	velocity = global_position.direction_to(targetPosition) * speed
	look_at(targetPosition) # the arrow need to point to the enemy
	move_and_slide()

# When the arrow makes contact with the enemy, it reduces his health points
# Using his value of damage and then disappear from the map
func _on_area_2d_body_entered(body: Node2D) -> void:
	var enemy = body.get_parent()
	if "health" in enemy:
		enemy.health -= bulletDamage
		queue_free()
