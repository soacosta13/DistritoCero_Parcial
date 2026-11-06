class_name ZombieTonto
extends EnemigoBase

# Este zombie corre más, pero no piensa: siempre va en línea recta hacia mi posición.
func _configurar_enemigo() -> void:
	velocidad = 150.0
	puntos_vida = 2
	puntos_por_baja = 100


# Sobreescribo el método del padre. Si hay una pared en el medio, me quedo empujándola.
func calcular_direccion_movimiento() -> Vector2:
	if objetivo_jugador == null:
		return Vector2.ZERO
	return global_position.direction_to(objetivo_jugador.global_position)
