extends PathFollow2D
class_name enemyData 

# Variables comunes (vacías por defecto)
var speed: float = 0.0
var hp: int = 0
var gold_reward: int = 0

func _process(delta: float) -> void:
	progress += speed * delta
	
	# Opcional: Si llega al final del camino, se borra (y te quita vidas a ti)
	if progress_ratio >= 1.0:
		queue_free()

# Función para recibir daño (La llamará la Torre)
func take_damage(damage_amount: int):
	hp -= damage_amount
	
	# Efecto visual opcional (parpadeo rojo)
	modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	if hp <= 0:
		die()

func die():
	# AQUÍ DARÍAMOS EL ORO AL JUGADOR
	# Ejemplo: GameData.gold += gold_reward
	print("Enemigo muerto. Ganaste: ", gold_reward, " monedas.")
	
	queue_free() # Eliminar al enemigo del juego
