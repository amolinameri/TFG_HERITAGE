extends CharacterBody2D

@export var speed: float = 200.0
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if direction == Vector2.ZERO:
		return

	var collision := move_and_collide(direction * speed * delta)
	if collision:
		var collider := collision.get_collider()
		if collider is Node and collider.is_in_group("enemies"):
			collider.queue_free() 
		queue_free()
