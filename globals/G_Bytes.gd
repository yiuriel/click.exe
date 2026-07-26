extends Node


signal bytes_changed(nuevos_bytes: int)

# Variable global con un setter
var bytes: int = 1000000000000:
	set(valor):
		bytes = valor
		# Emitimos la señal pasando el nuevo valor
		bytes_changed.emit(bytes)
