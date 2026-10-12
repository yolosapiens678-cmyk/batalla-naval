extends Control

func _on_btn_facil_pressed() -> void:
	GestorTurnos.dificultad_elegida = IA.Dificultad.FACIL
	get_tree().change_scene_to_file("res://main.tscn")

func _on_btn_medio_pressed() -> void:
	GestorTurnos.dificultad_elegida = IA.Dificultad.MEDIO
	get_tree().change_scene_to_file("res://main.tscn")


func _on_btn_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_inicio.tscn")
	

func _on_btn_dificl_pressed() -> void:
	GestorTurnos.dificultad_elegida = IA.Dificultad.DIFICIL
	get_tree().change_scene_to_file("res://main.tscn")
