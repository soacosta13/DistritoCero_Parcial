extends Control

# Mantengo tres tamaños habituales para que el selector sea corto y fácil de probar.
const RESOLUCIONES: Array[Vector2i] = [
	Vector2i(1152, 648),
	Vector2i(1280, 720),
	Vector2i(1600, 900)
]

@onready var contenedor_botones: VBoxContainer = $ContenedorBotones
@onready var panel_opciones: Panel = $PanelOpciones
@onready var deslizador_volumen: HSlider = $PanelOpciones/ContenedorOpciones/DeslizadorVolumen
@onready var selector_resolucion: OptionButton = $PanelOpciones/ContenedorOpciones/SelectorResolucion
@onready var etiqueta_record: Label = $EtiquetaRecord


func _ready() -> void:
	# Arranco mostrando las cuatro opciones y dejo el panel secundario cerrado.
	contenedor_botones.visible = true
	panel_opciones.visible = false

	selector_resolucion.clear()
	selector_resolucion.add_item("1152 x 648")
	selector_resolucion.add_item("1280 x 720")
	selector_resolucion.add_item("1600 x 900")

	# Leo la ventana real para que el selector no muestre un valor inventado.
	var tamano_actual: Vector2i = DisplayServer.window_get_size()
	var indice_actual: int = RESOLUCIONES.find(tamano_actual)
	selector_resolucion.select(maxi(indice_actual, 0))

	var indice_master: int = AudioServer.get_bus_index("Master")
	if indice_master >= 0:
		deslizador_volumen.value = db_to_linear(AudioServer.get_bus_volume_db(indice_master))

	etiqueta_record.text = "ÚLTIMA PARTIDA: %d     |     RÉCORD: %d" % [
		GameManager.puntaje_anterior,
		GameManager.mejor_puntaje
	]


func _on_boton_nivel_1_pressed() -> void:
	GameManager.iniciar_partida(1)
	await Transicion.cambiar_escena("res://escenas/nivel_1.tscn")


func _on_boton_nivel_2_pressed() -> void:
	# Dejo que se pueda entrar directamente al segundo nivel desde el menú para probarlo.
	GameManager.iniciar_partida(2)
	await Transicion.cambiar_escena("res://escenas/nivel_2.tscn")


func _on_boton_opciones_pressed() -> void:
	contenedor_botones.visible = false
	panel_opciones.visible = true


func _on_boton_salir_pressed() -> void:
	get_tree().quit()


func _on_boton_volver_pressed() -> void:
	panel_opciones.visible = false
	contenedor_botones.visible = true


func _on_deslizador_volumen_value_changed(valor: float) -> void:
	# AudioServer trabaja en decibeles; convierto el valor lineal de la barra antes de aplicarlo.
	var indice_master: int = AudioServer.get_bus_index("Master")
	if indice_master >= 0:
		AudioServer.set_bus_volume_db(indice_master, linear_to_db(maxf(valor, 0.001)))


func _on_selector_resolucion_item_selected(indice: int) -> void:
	if indice >= 0 and indice < RESOLUCIONES.size():
		DisplayServer.window_set_size(RESOLUCIONES[indice])
