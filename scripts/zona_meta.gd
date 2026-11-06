class_name ZonaMeta
extends Area2D

@export_file("*.tscn") var ruta_siguiente_escena: String = "res://escenas/menu_principal.tscn"
@export var es_final_del_juego: bool = false

@onready var fondo_puerta: ColorRect = $FondoPuerta
@onready var etiqueta_puerta: Label = $EtiquetaPuerta
@onready var bloqueo: CollisionShape2D = $Bloqueo/ColisionBloqueo

var puerta_abierta: bool = false
var temporizador_estado: float = 0.0
var cambiando: bool = false


func _ready() -> void:
	# La puerta arranca cerrada; el StaticBody2D impide que el jugador se cuele antes de tiempo.
	puerta_abierta = false
	_actualizar_cartel()


func _process(delta: float) -> void:
	# Reviso el grupo en intervalos cortos para abrir la puerta apenas desaparece el último zombie.
	temporizador_estado -= delta
	if temporizador_estado <= 0.0:
		temporizador_estado = 0.15
		if not puerta_abierta and get_tree().get_nodes_in_group("enemigos").is_empty():
			puerta_abierta = true
			bloqueo.set_deferred("disabled", true)
			_actualizar_cartel()

	# Si el jugador llegó a la puerta cuando todavía estaba cerrada, no lo obligo a salir y entrar otra vez.
	if puerta_abierta and not cambiando:
		for cuerpo in get_overlapping_bodies():
			if cuerpo is Jugador:
				_iniciar_cambio_de_nivel()
				break


func _actualizar_cartel() -> void:
	if puerta_abierta:
		fondo_puerta.color = Color("#35c99a")
		etiqueta_puerta.text = "PUERTA\nABIERTA"
	else:
		fondo_puerta.color = Color("#a33f50")
		etiqueta_puerta.text = "PUERTA\nBLOQUEADA"


func _on_body_entered(cuerpo: Node2D) -> void:
	# También respondo a la señal para que el cruce sea inmediato si ya estaba desbloqueada.
	if puerta_abierta and cuerpo is Jugador:
		_iniciar_cambio_de_nivel()


func _iniciar_cambio_de_nivel() -> void:
	if cambiando:
		return
	cambiando = true
	if es_final_del_juego:
		GameManager.cerrar_partida()
	# No vuelvo a tocar esta instancia después del cambio: pertenece a la escena que se va a cerrar.
	await Transicion.cambiar_escena(ruta_siguiente_escena)
