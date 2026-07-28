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
	1: 30,
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

var level_data_per_level: Dictionary[int, Dictionary] = {
	1: {
		"sector": "Disquete",
		"boss": "Trojan.exe"
	},
	2: {
		"sector": "Disco HDD",
		"boss": "Adware.dll"
	},
	3: {
		"sector": "Memoria RAM",
		"boss": "Keylogger.sys"
	},
	4: {
		"sector": "Caché L3",
		"boss": "Ransomware.zip"
	},
	5: {
		"sector": "Disco SSD",
		"boss": "CryptoMiner.hash"
	},
	6: {
		"sector": "Tarjeta GPU",
		"boss": "Glitcher.vbs"
	},
	7: {
		"sector": "Fibra Óptica",
		"boss": "DDoS_Bot.net"
	},
	8: {
		"sector": "Servidor Cloud",
		"boss": "Rootkit.kernel"
	},
	9: {
		"sector": "Red Cuántica",
		"boss": "ZeroDay.exploit"
	},
	10: {
		"sector": "Kernel Global",
		"boss": "KERNEL PANIC"
	}
}

var is_boss_fight = false

func start_boss_fight() -> void:
	is_boss_fight = true
	
func end_boss_fight() -> void:
	is_boss_fight = false

func get_previous_level_goal() -> int:
	if level == 0:
		return 0
	
	return goal_per_level[level - 1]

func get_level_data_per_level() -> Variant:
	return level_data_per_level[level]

func get_goal_per_level() -> int:
	return goal_per_level[level]

func is_current_level_finished() -> bool:
	return GlobalData.bytes >= goal_per_level[level]
