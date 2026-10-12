extends Control

@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var btn_volver: Button = %BtnVolver

func _ready() -> void:
	if btn_volver:
		btn_volver.pressed.connect(_on_btn_volver_pressed)

	if rich_text_label:
		rich_text_label.bbcode_enabled = true
		rich_text_label.text = """[font_size=20][color=#ffcc00][b]🎯 OBJETIVO DEL JUEGO[/b][/color][/font_size]
Encuentra y destruye toda la flota enemiga antes de que la Inteligencia Artificial hunda tus barcos.

[font_size=18][color=#3399ff][b]🚢 FASE 1: COLOCACIÓN DE BARCOS[/b][/color][/font_size]
• Tienes una flota de [b]5 barcos[/b] (tamaños: 4, 3, 2, 2 y 1 casillas).
• [b]Toca / Clic[/b] en tu tablero (izquierda) para posicionar cada barco.
• [b]Rotar:[/b] Usa el botón 'Rotar Barco' en pantalla o haz [b]clic derecho[/b] en PC.

[font_size=18][color=#3399ff][b]💥 FASE 2: BATALLA POR TURNOS[/b][/color][/font_size]
• Toca una casilla en el tablero rival (derecha) para disparar.
• Rojo: Fallaste | Verde: Impacto 
• Tienes [b]15 segundos[/b] por turno.

[font_size=18][color=#3399ff][b]⚙️ DIFICULTADES DE LA IA[/b][/color][/font_size]
• [b]Fácil:[/b] Disparos 100% aleatorios.
• [b]Medio:[/b] Cacería básica (al acertar, ataca alrededor).
• [b]Difícil:[/b] Patrón damero y estrategia de búsqueda avanzada."""

func _on_btn_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_inicio.tscn")
