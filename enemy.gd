extends Node2D

var path_follow: PathFollow2D
@export var speed: float = 20

func _ready() -> void:
	add_to_group("enemies")

func _process(delta: float) -> void:
	if path_follow == null:
		return

	path_follow.progress += speed * delta
	global_position = path_follow.global_position

	if path_follow.progress_ratio >= 1.0:
		queue_free()
