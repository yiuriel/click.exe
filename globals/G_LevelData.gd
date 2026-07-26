extends Node

signal level_change(new_level: int)

var level = 0:
	set(new_level):
		level = new_level
		# Emitimos la señal pasando el nuevo valor
		level_change.emit(level)

func level_up() -> void:
	level += 1

var goal_per_level = {
	0: 20,
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

func get_previous_level_goal() -> int:
	if level == 0:
		return 0
	
	return goal_per_level[level - 1]

func get_goal_per_level() -> int:
	return goal_per_level[level]

func is_current_level_finished() -> bool:
	return GlobalData.bytes >= goal_per_level[level]
