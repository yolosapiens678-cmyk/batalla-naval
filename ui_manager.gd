class_name UIManager
extends RefCounted

var grid_jugador: GridContainer
var grid_rival: GridContainer
var tiempo_label: Label
var estado_label: Label

var btn_reiniciar: Button
var btn_menu: Button
var btn_ayuda: Button
var btn_rotar: Button

var overlay_reglas: Control

func _init(p_grid_j: GridContainer, p_grid_r: GridContainer, p_tiempo: Label, p_estado: Label) -> void:
	grid_jugador = p_grid_j
	grid_rival = p_grid_r
	tiempo_label = p_tiempo
	estado_label = p_estado

func crear_tableros_visuales(callable_casilla: Callable) -> void:
	_generar_grid(grid_jugador, "jugador", callable_casilla)
	_generar_grid(grid_rival, "rival", callable_casilla)

func limpiar_tableros_visuales() -> void:
	for child in grid_jugador.get_children():
		child.queue_free()
	for child in grid_rival.get_children():
		child.queue_free()

func _generar_grid(grid: GridContainer, tipo_tablero: String, callable_casilla: Callable) -> void:
	for y in range(Tablero.ALTO):
		for x in range(Tablero.ANCHO):
			var boton = Button.new()
			boton.custom_minimum_size = Vector2(32, 32)
			boton.set_meta("x", x)
			boton.set_meta("y", y)
			boton.set_meta("tablero", tipo_tablero)
			boton.pressed.connect(callable_casilla.bind(boton))
			grid.add_child(boton)

func actualizar_vista_tableros(tablero_j: Tablero, tablero_r: Tablero) -> void:
	_actualizar_grid(grid_jugador, tablero_j.matriz, true)
	_actualizar_grid(grid_rival, tablero_r.matriz, false)

func _actualizar_grid(grid: GridContainer, matriz: Array, mostrar_barcos: bool) -> void:
	for boton in grid.get_children():
		var x = boton.get_meta("x")
		var y = boton.get_meta("y")
		var estado = matriz[y][x]
		var estilo = UIEstilos.obtener_estilo_casilla(estado, mostrar_barcos)
		boton.add_theme_stylebox_override("normal", estilo)

# BOTONES DE CONTROL SUPERIORES (ALINEADOS EN COLUMNA VERTICAL)
func crear_controles_superiores(parent: Node, callable_reiniciar: Callable, callable_menu: Callable, callable_rotar: Callable) -> void:
	# Contenedor vertical para organizar los botones en columna
	var contenedor_botones = VBoxContainer.new()
	contenedor_botones.position = Vector2(10, 10)
	contenedor_botones.add_theme_constant_override("separation", 10) # Espacio vertical entre cada botón

	# Ancho uniforme para que toda la columna se vea alineada
	var ancho_columna = 120
	var alto_boton = 32

	# 1. Botón Reiniciar
	btn_reiniciar = Button.new()
	btn_reiniciar.text = "🔄 Reiniciar"
	btn_reiniciar.custom_minimum_size = Vector2(ancho_columna, alto_boton)
	btn_reiniciar.pressed.connect(callable_reiniciar)
	contenedor_botones.add_child(btn_reiniciar)

	# 2. Botón para volver al Menu Principal
	btn_menu = Button.new()
	btn_menu.text = "🏠 Menú"
	btn_menu.custom_minimum_size = Vector2(ancho_columna, alto_boton)
	btn_menu.pressed.connect(callable_menu)
	contenedor_botones.add_child(btn_menu)

	# 3. Botón Tutorial
	btn_ayuda = Button.new()
	btn_ayuda.text = "❓ Cómo Jugar"
	btn_ayuda.custom_minimum_size = Vector2(ancho_columna, alto_boton)
	btn_ayuda.pressed.connect(mostrar_reglas)
	contenedor_botones.add_child(btn_ayuda)

	# 4. Botón Rotar Barco
	btn_rotar = Button.new()
	btn_rotar.text = "🔄 Rotar Barco"
	btn_rotar.custom_minimum_size = Vector2(ancho_columna, alto_boton)
	btn_rotar.pressed.connect(callable_rotar)
	btn_rotar.visible = false
	contenedor_botones.add_child(btn_rotar)

	parent.add_child(contenedor_botones)

	# Pestaña emergente de las reglas
	_crear_overlay_reglas(parent)

func _crear_overlay_reglas(parent: Node) -> void:
	overlay_reglas = Control.new()
	overlay_reglas.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay_reglas.visible = false
	overlay_reglas.z_index = 100

	# Fondo Oscuro Semitransparente
	var dim_bg = ColorRect.new()
	dim_bg.color = Color(0, 0, 0, 0.8)
	dim_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay_reglas.add_child(dim_bg)

	# Contenedor Centrado
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_CENTER)
	margin.custom_minimum_size = Vector2(460, 300)
	margin.grow_horizontal = Control.GROW_DIRECTION_BOTH
	margin.grow_vertical = Control.GROW_DIRECTION_BOTH
	overlay_reglas.add_child(margin)

	var panel = PanelContainer.new()
	margin.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var titulo = Label.new()
	titulo.text = "¿CÓMO JUGAR?"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo)

	var rtl = RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.custom_minimum_size = Vector2(420, 200)
	rtl.text = """[font_size=16][color=#ffcc00][b]🎯 OBJETIVO[/b][/color][/font_size]
Hunde la flota de la IA antes de que destruya tus barcos.

[font_size=16][color=#3399ff][b]🚢 COLOCACIÓN[/b][/color][/font_size]
• Toca tu tablero para ubicar tus 5 barcos.
• Usa 'Rotar Barco' o Clic Derecho para orientarlo.

[font_size=16][color=#3399ff][b]💥 BATALLA[/b][/color][/font_size]
• Dispara al tablero rival en tu turno (60s).
• Rojo: Fallaste | Verde: Impacto """
	vbox.add_child(rtl)

	var btn_cerrar = Button.new()
	btn_cerrar.text = "✖ Entendido / Cerrar"
	btn_cerrar.custom_minimum_size = Vector2(0, 35)
	btn_cerrar.pressed.connect(func(): overlay_reglas.visible = false)
	vbox.add_child(btn_cerrar)

	parent.add_child(overlay_reglas)

func mostrar_reglas() -> void:
	if overlay_reglas:
		overlay_reglas.visible = true

func mostrar_boton_rotar(mostrar: bool) -> void:
	if btn_rotar:
		btn_rotar.visible = mostrar

func set_estado(texto: String) -> void:
	estado_label.text = texto

func set_tiempo(texto: String) -> void:
	tiempo_label.text = texto
