class_name UIEstilos
extends RefCounted

static func obtener_estilo_casilla(estado: Tablero.Estado, mostrar_barcos: bool) -> StyleBoxFlat:
	var estilo = StyleBoxFlat.new()
	estilo.corner_radius_top_left = 3
	estilo.corner_radius_top_right = 3
	estilo.corner_radius_bottom_left = 3
	estilo.corner_radius_bottom_right = 3
	
	match estado:
		Tablero.Estado.VACIO:
			estilo.bg_color = Color(0.1, 0.35, 0.65) # Azul Agua
		Tablero.Estado.BARCO:
			if mostrar_barcos:
				estilo.bg_color = Color(0.55, 0.27, 0.07) # Café Barco
			else:
				estilo.bg_color = Color(0.1, 0.35, 0.65) # Oculto en rival
		Tablero.Estado.AGUA:
			estilo.bg_color = Color(0.85, 0.2, 0.2) # Rojo Fallo
		Tablero.Estado.TOCADO:
			estilo.bg_color = Color(0.18, 0.72, 0.25) # Verde Acierto
			
	return estilo
