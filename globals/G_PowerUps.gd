extends Node


var power_ups = {
	"data_leak": {
		"action": "add",
		"value": 25,
		"label": "Data leak"
	},
	"security_breach": {
		"action": "multiply",
		"value": 1.05,
		"label": "Sec. Breach"
	}
}

var power_up_timer = 5

func handle_power_up(power_up: Variant, bytes: int) -> int:
	var power_up_value = power_up.get('value')
	if power_up.get('action') == "add":
		return bytes + power_up_value
	elif power_up.get('action') == "multiply":
		return bytes * power_up_value	
	return bytes

func is_power_up_available() -> bool:
	return !LevelData.is_current_level_finished()

func get_power_up() -> Variant:
	if is_power_up_available():
		return pick_random(power_ups)
	return null
		
func pick_random(dictionary: Dictionary) -> Variant:
	var random_key = dictionary.keys().pick_random()
	return dictionary[random_key]
