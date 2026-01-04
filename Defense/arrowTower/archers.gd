extends Node2D

@onready var animBack: AnimatedSprite2D   = $AnimatedSprite2D2
@onready var animLeft: AnimatedSprite2D = $AnimatedSprite2D3
@onready var animRight: AnimatedSprite2D  = $AnimatedSprite2D4
@onready var animFront: AnimatedSprite2D  = $AnimatedSprite2D5

func _ready() -> void:
	animLeft.play("leftRightShooting")
	animFront.play("shootingFrontMotion")
	animBack.play("backShooting")
	animRight.play("leftRightShooting")
