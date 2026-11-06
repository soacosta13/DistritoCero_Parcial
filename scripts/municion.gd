extends Area2D

const CANTIDAD_MUNICION: int = 12


func _on_body_entered(cuerpo: Node2D) -> void:
	if cuerpo is Jugador:
		var jugador: Jugador = cuerpo as Jugador
		jugador.reponer_municion(CANTIDAD_MUNICION)
		GameManager.sumar_puntos(25)
		queue_free()
