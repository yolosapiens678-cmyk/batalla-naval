extends Control

const TAMANOS_BARCOS: Array = [4, 3, 2, 2, 1]
enum Fase { COLOCACION, JUEGO, FIN }

var tablero_j: Tablero = Tablero.new()
var tablero_r: Tablero = Tablero.new()
var ia_enemiga: IA
var ui: UIManager
var turnos: GestorTurnos

var indice_barco: int = 0
var es_horizontal: bool = true
var fase_actual: Fase = Fase.COLOCACION
var es_turno_jugador: bool = true

@onready var grid_j: GridContainer = $LayoutPrincipal/ContenedorTableros/SeccionJugador/GridJugador
@onready var grid_r: GridContainer = $LayoutPrincipal/ContenedorTableros/SeccionRival/GridRival
@onready var tiempo_label: Label = $LayoutPrincipal/TiempoLabel
@onready var estado_label: Label = $LayoutPrincipal/EstadoTurnoLabel

func _ready() -> void:
	$LayoutPrincipal/ContenedorTableros.add_theme_constant_override("separation", 25)
	ui = UIManager.new(grid_j, grid_r, tiempo_label, estado_label)
	ui.crear_tableros_visuales(_on_casilla_presionada)
	
	# Pasamos la función para reiniciar, volver al menú y rotar barco
	ui.crear_controles_superiores(self, reiniciar_juego, volver_al_menu, alternar_orientacion_barco)
	
	turnos = GestorTurnos.new(self)
	turnos.segundo_transcurrido.connect(_on_segundo_transcurrido)
	turnos.tiempo_agotado.connect(cambiar_turno)
	
	var dif = GestorTurnos.dificultad_elegida
	iniciar_fase_colocacion(dif)

func volver_al_menu() -> void:
	if turnos:
		turnos.detener()
	get_tree().change_scene_to_file("res://menu_inicio.tscn")

func iniciar_fase_colocacion(dif: IA.Dificultad) -> void:
	ia_enemiga = IA.new(dif)
	fase_actual = Fase.COLOCACION
	ui.mostrar_boton_rotar(true)
	actualizar_prompt_colocacion()
	ui.set_tiempo("Fase de preparación")
	ui.actualizar_vista_tableros(tablero_j, tablero_r)

func alternar_orientacion_barco() -> void:
	if fase_actual == Fase.COLOCACION:
		es_horizontal = !es_horizontal
		actualizar_prompt_colocacion()

func reiniciar_juego() -> void:
	if turnos:
		turnos.detener()
	get_tree().reload_current_scene()

func _gui_input(event: InputEvent) -> void:
	if fase_actual == Fase.COLOCACION and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		alternar_orientacion_barco()

func actualizar_prompt_colocacion() -> void:
	var ori = "Horizontal" if es_horizontal else "Vertical"
	var nombres_dif = {
		IA.Dificultad.FACIL: "FÁCIL",
		IA.Dificultad.MEDIO: "MEDIO",
		IA.Dificultad.DIFICIL: "DIFÍCIL"
	}
	var dif_txt = nombres_dif.get(ia_enemiga.dificultad, "NORMAL")
	ui.set_estado("Modo: " + dif_txt + " | Coloca tu barco (Largo: " + str(TAMANOS_BARCOS[indice_barco]) + ") | Orientación: " + ori)

func _on_casilla_presionada(boton: Button) -> void:
	var tipo = boton.get_meta("tablero")
	var x = boton.get_meta("x")
	var y = boton.get_meta("y")
	
	if fase_actual == Fase.COLOCACION and tipo == "jugador":
		if tablero_j.es_posicion_valida(x, y, TAMANOS_BARCOS[indice_barco], es_horizontal):
			tablero_j.agregar_barco(x, y, TAMANOS_BARCOS[indice_barco], es_horizontal)
			indice_barco += 1
			ui.actualizar_vista_tableros(tablero_j, tablero_r)
			if indice_barco < TAMANOS_BARCOS.size():
				actualizar_prompt_colocacion()
			else:
				ui.mostrar_boton_rotar(false)
				colocar_barcos_ia()
				fase_actual = Fase.JUEGO
				ui.set_estado("¡Batalla iniciada! Selecciona una casilla rival.")
				iniciar_turno()
	elif fase_actual == Fase.JUEGO and tipo == "rival" and es_turno_jugador:
		disparo_jugador(x, y)

func colocar_barcos_ia() -> void:
	for largo in TAMANOS_BARCOS:
		var colocado = false
		while not colocado:
			var rx = randi() % Tablero.ANCHO
			var ry = randi() % Tablero.ALTO
			var r_h = randi() % 2 == 0
			if tablero_r.es_posicion_valida(rx, ry, largo, r_h):
				tablero_r.agregar_barco(rx, ry, largo, r_h)
				colocado = true

func iniciar_turno() -> void:
	turnos.reiniciar()
	_actualizar_texto_tiempo(GestorTurnos.TIEMPO_MAXIMO)

func _on_segundo_transcurrido(tiempo: int) -> void:
	_actualizar_texto_tiempo(tiempo)

func _actualizar_texto_tiempo(tiempo: int) -> void:
	var txt = "Tu turno: " if es_turno_jugador else "Turno IA: "
	ui.set_tiempo(txt + str(tiempo) + "s")

func disparo_jugador(x: int, y: int) -> void:
	var res = tablero_r.recibir_disparo(x, y)
	if res == "REPETIDO": return
	
	var msgs = {"TOCADO": "¡IMPACTO!", "HUNDIDO": "¡BARCO HUNDIDO!", "AGUA": "¡AGUA!"}
	ui.set_estado(msgs.get(res, ""))
	ui.actualizar_vista_tableros(tablero_j, tablero_r)
	
	if not tablero_r.quedan_barcos_vivos():
		finalizar_juego("¡FELICIDADES! Destruiste la flota rival.")
	else:
		cambiar_turno()

func cambiar_turno() -> void:
	if fase_actual != Fase.JUEGO: return
	es_turno_jugador = !es_turno_jugador
	iniciar_turno()
	if not es_turno_jugador:
		get_tree().create_timer(1.2).timeout.connect(disparo_ia)

func disparo_ia() -> void:
	if fase_actual != Fase.JUEGO: return
	var celda = ia_enemiga.obtener_disparo(tablero_j)
	var res = tablero_j.recibir_disparo(celda.x, celda.y)
	ia_enemiga.registrar_resultado(celda, res, tablero_j)
	
	var msgs = {"TOCADO": "¡LA IA IMPACTÓ TU BARCO!", "HUNDIDO": "¡LA IA HUNDIÓ TU BARCO!", "AGUA": "La IA disparó al agua."}
	ui.set_estado(msgs.get(res, ""))
	ui.actualizar_vista_tableros(tablero_j, tablero_r)
	
	if not tablero_j.quedan_barcos_vivos():
		finalizar_juego("¡DERROTA! La IA destruyó tu flota.")
	else:
		cambiar_turno()

func finalizar_juego(mensaje: String) -> void:
	# 1. Detenemos la partida y bloqueamos clics de inmediato
	fase_actual = Fase.FIN
	es_turno_jugador = false
	if turnos:
		turnos.detener()
	
	ui.set_estado(mensaje)
	ui.set_tiempo("¡Fin de la partida!")
	
	# 2. Pausa automática de 0.5 segundos para apreciar el tiro ganador/perdedor
	await get_tree().create_timer(0.5).timeout
	
	# 3. Cambio de escena automático
	if "FELICIDADES" in mensaje or "Destruiste" in mensaje:
		get_tree().change_scene_to_file("res://victoria.tscn")
	else:
		get_tree().change_scene_to_file("res://derrota.tscn")
