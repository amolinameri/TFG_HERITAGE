extends Node2D

@export var enemy_scene: PackedScene
@export var wave_size: int = 5
@export var spawn_interval: float = 2.0

@onready var path: Path2D = $Path2D
var path_follow: PathFollow2D

func _ready() -> void:
	path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	path_follow.loop = false

	$Timer.timeout.connect(_on_Timer_timeout)
	$Timer.start()

func _on_Timer_timeout() -> void:
	for i in range(wave_size):
		if enemy_scene == null:
			push_warning("Error charging enemy")
			return
		var enemy = enemy_scene.instantiate()
		path_follow.add_child(enemy)
		enemy.global_position = path_follow.global_position
		enemy.path_follow = path_follow
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		var tower_scene: PackedScene = preload("res://Tower.tscn")
		var tower: Node2D = tower_scene.instantiate()
		tower.global_position = get_global_mouse_position()

		var space_state := get_world_2d().direct_space_state

		var params := PhysicsPointQueryParameters2D.new()
		params.position = tower.global_position
		params.collide_with_bodies = true
		params.collide_with_areas = true
		

		var result := space_state.intersect_point(params, 1)

		if result.is_empty():
			add_child(tower)
