extends Node2D

var spikeDamage= GameValues.spikeDamage
#how many more mobs can step in before it is destroyed
var usesLeft = GameValues.spikeUses
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var mob
var alreadyHit = []

func _ready() -> void:
	anim.play("default")
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	# if there is a flying mob, then it would not be affected, otherwise...
	if body.is_in_group("flyingMob"):
		return
	
	# we get him and then we aply to them slowness
	mob = body.get_parent()
	if mob == null or not (mob is PathFollow2D):
		return
	mob._apply_slow()

	# a mob can only be hitten by the spike once
	if  mob in alreadyHit:
		return
	alreadyHit.append(mob)
	mob.health -= spikeDamage
	#if the spikes has gotten to his limits, we erased it
	usesLeft -= 1
	if usesLeft <= 0:
		queue_free()
