extends Node2D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 1.0

var can_fire: bool = true

func _ready() -> void:
	if $Timer:
		$Timer.timeout.connect(_on_Timer_timeout)

func _physics_process(delta: float) -> void:
	var closest_enemy: Node2D = null
	var closest_distance: float = INF

	for body in get_tree().get_nodes_in_group("enemies"):
		if not (body is Node2D):
			continue
		var distance := global_position.distance_to(body.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = body

	if closest_enemy != null and can_fire and projectile_scene != null:
		fire(closest_enemy.global_position)
		can_fire = false
		$Timer.start(1.0 / fire_rate)

func fire(target_position: Vector2) -> void:
	var projectile := projectile_scene.instantiate()
	get_parent().add_child(projectile)

	projectile.global_position = global_position
	projectile.direction = (target_position - global_position).normalized()

func _on_Timer_timeout() -> void:
	can_fire = true
