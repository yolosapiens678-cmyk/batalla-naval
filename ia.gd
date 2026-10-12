class_name IA
extends RefCounted

enum Dificultad { FACIL, MEDIO, DIFICIL }

var dificultad: Dificultad
var modo_caceria: bool = false
var ultimos_impactos: Array[Vector2i] = []
var objetivo_inicial: Vector2i = Vector2i(-1, -1)

func _init(p_dificultad: Dificultad) -> void:
	dificultad = p_dificultad

func obtener_disparo(tablero_jugador: Tablero) -> Vector2i:
	match dificultad:
		Dificultad.FACIL:
			return _disparo_aleatorio(tablero_jugador)
		Dificultad.MEDIO:
			if modo_caceria and ultimos_impactos.size() > 0:
				return _disparo_objetivo(tablero_jugador)
			return _disparo_aleatorio(tablero_jugador)
		Dificultad.DIFICIL:
			if modo_caceria and ultimos_impactos.size() > 0:
				return _disparo_objetivo(tablero_jugador)
			return _disparo_paridad_damero(tablero_jugador)
	return _disparo_aleatorio(tablero_jugador)

func _disparo_aleatorio(tablero: Tablero) -> Vector2i:
	var celdas_validas: Array[Vector2i] = []
	for y in range(Tablero.ALTO):
		for x in range(Tablero.ANCHO):
			if tablero.matriz[y][x] in [Tablero.Estado.VACIO, Tablero.Estado.BARCO]:
				celdas_validas.append(Vector2i(x, y))
	return celdas_validas.pick_random() if celdas_validas.size() > 0 else Vector2i(0, 0)

func _disparo_paridad_damero(tablero: Tablero) -> Vector2i:
	var celdas_damero: Array[Vector2i] = []
	for y in range(Tablero.ALTO):
		for x in range(Tablero.ANCHO):
			if (x + y) % 2 == 0 and tablero.matriz[y][x] in [Tablero.Estado.VACIO, Tablero.Estado.BARCO]:
				celdas_damero.append(Vector2i(x, y))
	if celdas_damero.size() > 0:
		return celdas_damero.pick_random()
	return _disparo_aleatorio(tablero)

func _disparo_objetivo(tablero: Tablero) -> Vector2i:
	var origen = ultimos_impactos.back()
	var direcciones = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	direcciones.shuffle()
	
	for dir in direcciones:
		var pos = origen + dir
		if pos.x >= 0 and pos.x < Tablero.ANCHO and pos.y >= 0 and pos.y < Tablero.ALTO:
			if tablero.matriz[pos.y][pos.x] in [Tablero.Estado.VACIO, Tablero.Estado.BARCO]:
				return pos
				
	for dir in direcciones:
		var pos = objetivo_inicial + dir
		if pos.x >= 0 and pos.x < Tablero.ANCHO and pos.y >= 0 and pos.y < Tablero.ALTO:
			if tablero.matriz[pos.y][pos.x] in [Tablero.Estado.VACIO, Tablero.Estado.BARCO]:
				return pos
				
	return _disparo_aleatorio(tablero)

func registrar_resultado(pos: Vector2i, resultado: String, tablero: Tablero) -> void:
	if dificultad == Dificultad.FACIL: return
	
	if resultado == "TOCADO":
		modo_caceria = true
		if ultimos_impactos.size() == 0:
			objetivo_inicial = pos
		ultimos_impactos.append(pos)
	elif resultado == "HUNDIDO":
		modo_caceria = false
		ultimos_impactos.clear()
		objetivo_inicial = Vector2i(-1, -1)
