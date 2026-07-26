extends Node

func _format_bytes(bytes: float) -> String:
	if bytes < 1024:
		return str(int(bytes)) + " B"
	elif bytes < 1024 * 1024:
		return "%.2f KB" % (bytes / 1024.0)
	elif bytes < 1024 * 1024 * 1024:
		return "%.2f MB" % (bytes / (1024.0 * 1024.0))
	else:
		return "%.2f GB" % (bytes / (1024.0 * 1024.0 * 1024.0))

var rng = RandomNumberGenerator.new()

func _get_random_screen_position(n1: float, n2: float) -> float:
	return rng.randf_range(n1, n2)
