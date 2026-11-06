extends CanvasLayer

# Uso una sola cortina negra para que el fundido sea igual entre menú y niveles.
@onready var cortina: ColorRect = $Cortina
var cambiando_escena: bool = false


func _ready() -> void:
	# El Autoload queda por encima de todas las escenas y nunca se destruye al cambiar de nivel.
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	cortina.modulate.a = 1.0
	cortina.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fundido(0.0, 0.45)
	cortina.mouse_filter = Control.MOUSE_FILTER_IGNORE


func cambiar_escena(ruta: String) -> void:
	if cambiando_escena:
		return
	cambiando_escena = true
	cortina.mouse_filter = Control.MOUSE_FILTER_STOP

	# Primero cubro la pantalla; recién cuando está negra cambio la escena.
	await _fundido(1.0, 0.35)
	var error: Error = get_tree().change_scene_to_file(ruta)
	if error != OK:
		push_error("No pude abrir la escena: " + ruta)
		await _fundido(0.0, 0.25)
		cortina.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cambiando_escena = false
		return

	# Espero un frame para que la nueva escena ya exista antes de descubrirla.
	await get_tree().process_frame
	await _fundido(0.0, 0.35)
	cortina.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cambiando_escena = false


func _fundido(alpha_final: float, duracion: float) -> void:
	var animacion := create_tween()
	animacion.tween_property(cortina, "modulate:a", alpha_final, duracion)
	await animacion.finished
