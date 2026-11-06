extends Node

# Guardo acá los datos que tienen que sobrevivir al cambio de escenas.
# Elegí un Autoload porque si los puntajes estuvieran dentro de un nivel se perderían al pasar al siguiente.
const ARCHIVO_RECORD: String = "user://distrito_cero_record.cfg"

var puntaje_actual: int = 0
var puntaje_anterior: int = 0
var mejor_puntaje: int = 0
var nivel_actual: int = 1


func _ready() -> void:
	_cargar_record()


func iniciar_partida(numero_nivel: int) -> void:
	# Empiezo una partida nueva desde cero. Al pasar de nivel no vuelvo a llamar este método.
	puntaje_actual = 0
	nivel_actual = numero_nivel


func sumar_puntos(cantidad: int) -> void:
	puntaje_actual += cantidad
	if puntaje_actual > mejor_puntaje:
		mejor_puntaje = puntaje_actual
		_guardar_record()


func cerrar_partida() -> void:
	# Guardo también el último resultado para mostrarlo en el menú al terminar el segundo nivel.
	puntaje_anterior = puntaje_actual
	if puntaje_actual > mejor_puntaje:
		mejor_puntaje = puntaje_actual
	_guardar_record()


func _cargar_record() -> void:
	var archivo := ConfigFile.new()
	var error: Error = archivo.load(ARCHIVO_RECORD)
	if error == OK:
		mejor_puntaje = int(archivo.get_value("puntajes", "mejor", 0))
		puntaje_anterior = int(archivo.get_value("puntajes", "ultimo", 0))


func _guardar_record() -> void:
	var archivo := ConfigFile.new()
	archivo.set_value("puntajes", "mejor", mejor_puntaje)
	archivo.set_value("puntajes", "ultimo", puntaje_actual)
	archivo.save(ARCHIVO_RECORD)
