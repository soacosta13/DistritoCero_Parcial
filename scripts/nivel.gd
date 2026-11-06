class_name Nivel
extends Node2D

# Mantengo una celda de 64 px porque los gráficos del pack Kenney que uso acá tienen ese tamaño.
const TAMANO_CELDA: int = 64

@export var numero_nivel: int = 1

@onready var piso_layer: TileMapLayer = $PisoLayer
@onready var paredes_layer: TileMapLayer = $ParedesLayer
@onready var jugador: Jugador = $Jugador
@onready var etiqueta_nivel: Label = $HUD/PanelHUD/ContenedorHUD/EtiquetaNivel
@onready var etiqueta_puntaje: Label = $HUD/PanelHUD/ContenedorHUD/EtiquetaPuntaje
@onready var etiqueta_municion: Label = $HUD/PanelHUD/ContenedorHUD/EtiquetaMunicion
@onready var etiqueta_zombies: Label = $HUD/PanelHUD/ContenedorHUD/EtiquetaZombies

var astar: AStarGrid2D = AStarGrid2D.new()


func _ready() -> void:
	# Las celdas ya están pintadas en cada escena. Así puedo ver y editar el mapa desde el editor.
	# También uso esas mismas celdas para el A*, para que los enemigos no tengan un mapa distinto del visual.
	_configurar_astar()
	GameManager.nivel_actual = numero_nivel
	etiqueta_nivel.text = "SECTOR %02d" % numero_nivel
	jugador.municion_actualizada.connect(_actualizar_municion)
	_actualizar_municion(jugador.municion_actual)


func _process(_delta: float) -> void:
	# Actualizo estos datos en pantalla porque pueden cambiar varias veces durante una pelea.
	etiqueta_puntaje.text = "PUNTAJE: %05d" % GameManager.puntaje_actual
	etiqueta_zombies.text = "ZOMBIES: %02d" % get_tree().get_nodes_in_group("enemigos").size()


func _actualizar_municion(cantidad: int) -> void:
	etiqueta_municion.text = "BALAS: %02d/30" % cantidad


func _configurar_astar() -> void:
	# Tomo el rectángulo real que ocupa el piso, no una grilla escrita por separado.
	astar.region = piso_layer.get_used_rect()
	astar.cell_size = Vector2(TAMANO_CELDA, TAMANO_CELDA)
	astar.offset = Vector2(TAMANO_CELDA / 2.0, TAMANO_CELDA / 2.0)
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

	# Cada tile de ParedesLayer es sólido. Leo las celdas directamente del TileMapLayer.
	for celda in paredes_layer.get_used_cells():
		astar.set_point_solid(celda, true)


func obtener_camino(posicion_inicio: Vector2, posicion_objetivo: Vector2) -> PackedVector2Array:
	# Paso las posiciones del mundo a las celdas que usan los TileMapLayer.
	var inicio: Vector2i = piso_layer.local_to_map(piso_layer.to_local(posicion_inicio))
	var destino: Vector2i = piso_layer.local_to_map(piso_layer.to_local(posicion_objetivo))

	# Si un personaje queda justo dentro de una celda bloqueada, lo llevo a la celda libre más cercana.
	inicio = _buscar_celda_libre_cercana(inicio)
	destino = _buscar_celda_libre_cercana(destino)
	if inicio.x < 0 or destino.x < 0:
		return PackedVector2Array()

	var ruta_local: PackedVector2Array = astar.get_point_path(inicio, destino)
	var ruta_mundo := PackedVector2Array()
	for punto in ruta_local:
		ruta_mundo.append(piso_layer.to_global(punto))
	return ruta_mundo


func _buscar_celda_libre_cercana(celda_origen: Vector2i) -> Vector2i:
	# Busco primero en la celda actual y después en anillos chicos alrededor.
	# Esto evita que el A* se quede sin camino si el centro de un personaje cae sobre un tile sólido.
	for radio in range(4):
		for y in range(-radio, radio + 1):
			for x in range(-radio, radio + 1):
				if abs(x) + abs(y) != radio:
					continue
				var celda := celda_origen + Vector2i(x, y)
				if astar.is_in_boundsv(celda) and not astar.is_point_solid(celda):
					return celda
	return Vector2i(-1, -1)
