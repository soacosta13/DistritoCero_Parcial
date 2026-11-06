class_name Jugador
extends CharacterBody2D

signal municion_actualizada(cantidad: int)

const VELOCIDAD_MOVIMIENTO: float = 240.0
const ESCENA_BALA: PackedScene = preload("res://escenas/bala.tscn")
const MUNICION_INICIAL: int = 18
const MUNICION_MAXIMA: int = 30

# Guardo los nodos una vez listos: la boca del arma y el sonido son hijos directos del jugador.
@onready var boca_arma: Marker2D = $BocaArma
@onready var sonido_disparo: AudioStreamPlayer2D = $SonidoDisparo

var municion_actual: int = MUNICION_INICIAL


func _ready() -> void:
	# Uso un grupo para que cualquier enemigo pueda encontrarme sin conocer el nombre del nodo.
	add_to_group("jugador")
	municion_actual = MUNICION_INICIAL
	municion_actualizada.emit(municion_actual)


func _physics_process(_delta: float) -> void:
	# get_vector normaliza la diagonal, así no me muevo más rápido por apretar dos teclas.
	var direccion: Vector2 = Input.get_vector(
		"mover_izquierda",
		"mover_derecha",
		"mover_arriba",
		"mover_abajo"
	)
	velocity = direccion * VELOCIDAD_MOVIMIENTO
	move_and_slide()

	# El sprite de Kenney mira a la derecha en rotación 0, por eso look_at apunta al mouse directamente.
	look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("disparar"):
		_disparar_pistola()


func _disparar_pistola() -> void:
	if municion_actual <= 0:
		return

	municion_actual -= 1
	municion_actualizada.emit(municion_actual)

	var nueva_bala: Bala = ESCENA_BALA.instantiate() as Bala
	# Agrego la bala al nivel antes de asignar global_position para que no herede el giro del jugador.
	get_tree().current_scene.add_child(nueva_bala)
	nueva_bala.global_position = boca_arma.global_position
	nueva_bala.global_rotation = global_rotation

	# Dejo el reproductor preparado: puedo asignarle un WAV desde el Inspector sin tocar la lógica del disparo.
	if sonido_disparo.stream != null:
		sonido_disparo.play()


func reponer_municion(cantidad: int) -> void:
	municion_actual = mini(municion_actual + cantidad, MUNICION_MAXIMA)
	municion_actualizada.emit(municion_actual)
