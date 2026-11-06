class_name EnemigoBase
extends CharacterBody2D

# Esta clase concentra lo que comparten los dos zombies. Los hijos solo deciden cómo perseguirme.
const DISTANCIA_ATAQUE: float = 36.0

var velocidad: float = 110.0
var puntos_vida: int = 3
var puntos_por_baja: int = 100
var objetivo_jugador: Node2D = null
var mapa_actual: Nivel = null
var reiniciando_nivel: bool = false


func _ready() -> void:
	add_to_group("enemigos")
	_configurar_enemigo()
	# Espero a que el árbol completo esté listo para encontrar al jugador y al mapa sin referencias nulas.
	call_deferred("_buscar_referencias")


func _buscar_referencias() -> void:
	objetivo_jugador = get_tree().get_first_node_in_group("jugador") as Node2D
	mapa_actual = get_tree().get_first_node_in_group("mapa") as Nivel


# Dejo este método vacío para que cada clase hija configure sus propios valores.
func _configurar_enemigo() -> void:
	pass


func _physics_process(_delta: float) -> void:
	# Si todavía no encontré las referencias, las vuelvo a buscar en vez de quedar quieto para siempre.
	if not is_instance_valid(objetivo_jugador) or not is_instance_valid(mapa_actual):
		_buscar_referencias()
	if objetivo_jugador == null or not is_instance_valid(objetivo_jugador):
		return

	# Esta llamada es polimórfica: Godot ejecuta la versión escrita por el hijo que creó al zombie.
	var direccion: Vector2 = calcular_direccion_movimiento()
	velocity = direccion * velocidad
	if direccion.length() > 0.01:
		rotation = direccion.angle()
	move_and_slide()
	_verificar_contacto_jugador()


# Los hijos sobreescriben este método con dos comportamientos distintos.
func calcular_direccion_movimiento() -> Vector2:
	return Vector2.ZERO


func recibir_danio(cantidad: int) -> void:
	puntos_vida -= cantidad
	if puntos_vida <= 0:
		_morir()


func _morir() -> void:
	GameManager.sumar_puntos(puntos_por_baja)
	_mostrar_particulas()
	queue_free()


func _mostrar_particulas() -> void:
	# Hago un pequeño estallido al morir para que el impacto se entienda visualmente.
	var particulas := CPUParticles2D.new()
	particulas.amount = 18
	particulas.lifetime = 0.45
	particulas.one_shot = true
	particulas.explosiveness = 1.0
	particulas.direction = Vector2.RIGHT
	particulas.spread = 180.0
	particulas.gravity = Vector2.ZERO
	particulas.initial_velocity_min = 55.0
	particulas.initial_velocity_max = 125.0
	particulas.scale_amount_min = 2.0
	particulas.scale_amount_max = 4.0
	particulas.color = Color("#ef5268")
	get_tree().current_scene.add_child(particulas)
	particulas.global_position = global_position
	particulas.emitting = true
	# No dependo del zombie para el tiempo de vida: lo libero cuando termina la animación.
	get_tree().create_timer(particulas.lifetime + 0.1).timeout.connect(particulas.queue_free)


func _verificar_contacto_jugador() -> void:
	if reiniciando_nivel or objetivo_jugador == null:
		return
	if global_position.distance_to(objetivo_jugador.global_position) <= DISTANCIA_ATAQUE:
		reiniciando_nivel = true
		# Si me alcanza un zombie, reinicio el nivel con el mismo fundido que uso para cambiar de escena.
		await Transicion.cambiar_escena(get_tree().current_scene.scene_file_path)
