class_name ZombieInteligente
extends EnemigoBase

# Este zombie camina más lento que el tonto, pero calcula un camino alrededor de las paredes.
func _configurar_enemigo() -> void:
	velocidad = 118.0
	puntos_vida = 3
	puntos_por_baja = 150


# Sobreescribo el movimiento del padre. Actualizo la posición del jugador en cada consulta.
func calcular_direccion_movimiento() -> Vector2:
	if objetivo_jugador == null or not is_instance_valid(objetivo_jugador):
		return Vector2.ZERO
	if mapa_actual == null or not is_instance_valid(mapa_actual):
		mapa_actual = get_tree().get_first_node_in_group("mapa") as Nivel
	if mapa_actual == null:
		return Vector2.ZERO

	# Calculo otra vez el recorrido para que el destino siga siendo la posición actual del jugador.
	var camino: PackedVector2Array = mapa_actual.obtener_camino(
		global_position,
		objetivo_jugador.global_position
	)

	if camino.size() > 1:
		# El primer punto es el centro de la celda donde ya estoy.
		# Voy al segundo punto; si vuelvo al primero, nunca salgo de la celda inicial.
		return global_position.direction_to(camino[1])
	if camino.size() == 1:
		# Si ya compartimos una celda, avanzo directamente hacia el jugador.
		return global_position.direction_to(objetivo_jugador.global_position)
	return Vector2.ZERO
