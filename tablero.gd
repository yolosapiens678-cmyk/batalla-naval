class_name Tablero
extends RefCounted

const ANCHO = 10
const ALTO = 10

enum Estado {VACIO, BARCO, AGUA, TOCADO}

var matriz: Array = []
var barcos: Array[Barco] = []

func _init() -> void:
	reiniciar()

func reiniciar() -> void:
	matriz.clear()
	barcos.clear()
	for y in range(ALTO):
		var fila = []
		for x in range(ANCHO):
			fila.append(Estado.VACIO)
		matriz.append(fila)

func es_posicion_valida(x: int, y: int, largo: int, horizontal: bool) -> bool:
	if horizontal:
		if x + largo > ANCHO: return false
		for i in range(largo):
			if matriz[y][x + i] != Estado.VACIO: return false
	else:
		if y + largo > ALTO: return false
		for i in range(largo):
			if matriz[y + i][x] != Estado.VACIO: return false
	return true

func agregar_barco(x: int, y: int, largo: int, horizontal: bool) -> void:
	var casillas: Array[Vector2i] = []
	for i in range(largo):
		var pos = Vector2i(x + i, y) if horizontal else Vector2i(x, y + i)
		matriz[pos.y][pos.x] = Estado.BARCO
		casillas.append(pos)
	barcos.append(Barco.new(casillas))

func recibir_disparo(x: int, y: int) -> String:
	var estado = matriz[y][x]
	if estado == Estado.AGUA or estado == Estado.TOCADO:
		return "REPETIDO"

	if estado == Estado.BARCO:
		matriz[y][x] = Estado.TOCADO
		var pos = Vector2i(x, y)
		for barco in barcos:
			if pos in barco.casillas:
				barco.registrar_impacto(pos)
				if barco.es_hundido():
					return "HUNDIDO"
				return "TOCADO"
	
	matriz[y][x] = Estado.AGUA
	return "AGUA"

func quedan_barcos_vivos() -> bool:
	for barco in barcos:
		if not barco.es_hundido():
			return true
	return false
