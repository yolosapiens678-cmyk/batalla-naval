class_name GestorTurnos
extends RefCounted

# Variable estática para compartir la dificultad elegida entre escenas
static var dificultad_elegida: IA.Dificultad = IA.Dificultad.FACIL

signal segundo_transcurrido(tiempo_restante: int)
signal tiempo_agotado

const TIEMPO_MAXIMO: int = 15

var tiempo_restante: int = TIEMPO_MAXIMO
var timer: Timer

func _init(nodo_padre: Node) -> void:
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timeout)
	nodo_padre.add_child(timer)

func reiniciar() -> void:
	tiempo_restante = TIEMPO_MAXIMO
	timer.start()

func detener() -> void:
	timer.stop()

func _on_timeout() -> void:
	tiempo_restante -= 1
	segundo_transcurrido.emit(tiempo_restante)
	if tiempo_restante <= 0:
		timer.stop()
		tiempo_agotado.emit()
