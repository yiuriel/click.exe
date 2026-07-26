extends Node

signal level_change(new_level: int)

var level = 1:
	set(new_level):
		level = new_level
		# Emitimos la señal pasando el nuevo valor
		level_change.emit(level)

func level_up() -> void:
	level += 1

var goal_per_level = {
	1: 1024,
	2: 8192,
	3: 65536,
	4: 524288,
	5: 4194304,
	6: 33554432,
	7: 268435456,
	8: 2147483648,
	9: 17179869184,
	10: 137438953472,
}

func is_current_level_finished() -> bool:
	return GlobalData.bytes >= goal_per_level[level]
