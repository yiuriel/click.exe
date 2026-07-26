extends Node

var directions: Array[Vector2] = [
	Vector2(1, -1),   # UP_RIGHT (Derecha y Arriba)
	Vector2(-1, -1),  # UP_LEFT (Izquierda y Arriba)
	Vector2(1, 1),    # DOWN_RIGHT (Derecha y Abajo)
	Vector2(-1, 1)    # DOWN_LEFT (Izquierda y Abajo)
]

func _get_random_direction() -> Vector2:
	var chosen_direction: Vector2 = directions.pick_random()
	return chosen_direction
