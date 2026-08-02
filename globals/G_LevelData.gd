extends Node

signal level_change(new_level: int)
signal game_state_changed(new_state: GameState)

enum GameState {
	GAME_LEVEL,               # Jugando el nivel, se pueden sumar bytes
	WAITING_FOR_INTERACTION,  # Nivel completo, se pueden sumar bytes y pelear
	BOSS_LEVEL,               # Pelea contra el jefe, no se suman bytes
	VICTORY,                  # Jefe derrotado, botón siguiente nivel
	DEFEAT,                   # Jefe fallido, botón reintentar pelea
}

var game_state: GameState = GameState.GAME_LEVEL:
	set(new_state):
		if game_state == new_state:
			return
		game_state = new_state
		game_state_changed.emit(game_state)

var level = 1:
	set(new_level):
		level = new_level
		# Emitimos la señal pasando el nuevo valor
		level_change.emit(level)

func level_up() -> void:
	level += 1
	game_state = GameState.GAME_LEVEL

func start_boss_fight() -> void:
	game_state = GameState.BOSS_LEVEL

func boss_fight_won() -> void:
	game_state = GameState.VICTORY

func boss_fight_lost() -> void:
	game_state = GameState.DEFEAT

func is_game_level() -> bool:
	return game_state == GameState.GAME_LEVEL

func is_waiting_interaction() -> bool:
	return game_state == GameState.WAITING_FOR_INTERACTION

func is_boss_level() -> bool:
	return game_state == GameState.BOSS_LEVEL

func is_victory() -> bool:
	return game_state == GameState.VICTORY

func is_defeat() -> bool:
	return game_state == GameState.DEFEAT

#var goal_per_level = {
	#1: 20,
	#2: 8192,
	#3: 65536,
	#4: 524288,
	#5: 4194304,
	#6: 33554432,
	#7: 268435456,
	#8: 2147483648,
	#9: 17179869184,
	#10: 137438953472,
#}

var goal_per_level = {
	1: 20,
	2: 60,
	3: 100,
	4: 140,
	5: 180,
	6: 220,
	7: 260,
	8: 300,
	9: 340,
	10: 400,
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

func get_previous_level_goal() -> int:
	if level <= 1:
		return 0
	
	return goal_per_level[level - 1]

func get_level_data_per_level() -> Variant:
	return level_data_per_level[level]

func get_goal_per_level() -> int:
	return goal_per_level[level]

func is_current_level_finished() -> bool:
	return GlobalData.bytes >= goal_per_level[level]
