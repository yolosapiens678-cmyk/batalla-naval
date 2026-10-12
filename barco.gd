class_name Barco
extends RefCounted

var casillas: Array[Vector2i] = []
var impactos: Array[Vector2i] = []

func _init(p_casillas: Array[Vector2i]) -> void:
	casillas = p_casillas

func registrar_impacto(pos: Vector2i) -> void:
	if pos in casillas and not pos in impactos:
		impactos.append(pos)

func es_hundido() -> bool:
	return impactos.size() == casillas.size()
