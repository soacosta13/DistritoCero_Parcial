class_name Bala
extends Area2D

const VELOCIDAD_BALA: float = 750.0
const DANIO_BALA: int = 1
const TIEMPO_VIDA_MAXIMO: float = 1.6

var tiempo_transcurrido: float = 0.0


func _physics_process(delta: float) -> void:
	# Como el ángulo 0 apunta a la derecha, roto Vector2.RIGHT para seguir la orientación del disparo.
	global_position += Vector2.RIGHT.rotated(global_rotation) * VELOCIDAD_BALA * delta

	# Destruyo la bala después de un rato para que los tiros que no pegaron no queden vivos para siempre.
	tiempo_transcurrido += delta
	if tiempo_transcurrido >= TIEMPO_VIDA_MAXIMO:
		queue_free()


func _on_body_entered(cuerpo: Node2D) -> void:
	# Uso grupos porque el proyectil no necesita distinguir entre los dos hijos de EnemigoBase.
	if cuerpo.is_in_group("jugador"):
		return
	if cuerpo.is_in_group("enemigos") and cuerpo.has_method("recibir_danio"):
		cuerpo.call("recibir_danio", DANIO_BALA)
		queue_free()
	else:
		# Cualquier otro cuerpo con colisión es una pared y frena el proyectil.
		queue_free()
