extends Node


signal bytes_changed(nuevos_bytes: int)

# Variable global con un setter
var bytes: int = 0:
	set(valor):
		bytes = valor
		# Emitimos la señal pasando el nuevo valor
		bytes_changed.emit(bytes)
