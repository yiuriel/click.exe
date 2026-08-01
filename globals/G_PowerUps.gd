extends Node


var power_ups = {
	"data_leak": {
		"action": "add",
		"value": 50,
		"label": "Data leak"
	},
	"security_breach": {
		"action": "multiply",
		"value": 1.1,
		"label": "Sec. Breach"
	},
	"virus": {
		"action": "subtract",
		"value": 35,
		"label": "Virus"
	},
	"virus_alert": {
		"action": "add",
		"value": 35,
		"label": "Virus Alert"
	}
}

var power_up_timer = 5

func handle_power_up(power_up: Variant, bytes: int) -> int:
	var power_up_value = power_up.get('value')
	if power_up.get('action') == "add":
		return bytes + power_up_value
	elif power_up.get('action') == "multiply":
		return bytes * power_up_value
	elif power_up.get('action') == "subtract":
		return max(bytes - power_up_value, LevelData.get_previous_level_goal())
	return bytes

func is_power_up_available() -> bool:
	return LevelData.is_game_level()

func get_power_up() -> Variant:
	if is_power_up_available():
		return pick_random(power_ups)
	return null
		
func pick_random(dictionary: Dictionary) -> Variant:
	var random_key = dictionary.keys().pick_random()
	return dictionary[random_key]
