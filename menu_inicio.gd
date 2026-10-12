extends Control

var icono_on = preload("res://icon_on.png")
var icono_off = preload("res://icon_off.png")

var audio_activado: bool = true

@onready var btn_audio: Button = $ContenedorMargen/LayoutVertical/BarraInferior/BtnAudio

func _ready() -> void:
	if btn_audio:
		btn_audio.icon = icono_on

func _on_btn_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://seleccion_dificultad.tscn")

func _on_btn_como_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://como_jugar.tscn")

func _on_btn_salir_pressed() -> void:
	get_tree().quit()

func _on_btn_audio_pressed() -> void:
	audio_activado = !audio_activado
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_index, !audio_activado)
	
	if audio_activado:
		btn_audio.icon = icono_on
	else:
		btn_audio.icon = icono_off
