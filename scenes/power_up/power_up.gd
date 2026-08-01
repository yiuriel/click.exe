extends Node2D

class_name PowerUpScene

var power_up: Variant

var is_bad_power_up: bool

@onready var power_up_button: Button = find_child("PowerUpButton", true, false)

func add_data(incoming_power_up: Variant) -> void:
	if not incoming_power_up:
		return
		
	power_up = incoming_power_up

func set_power_up_position(x: float, y: float) -> void:
	position = Vector2(x, y)

func _ready() -> void:
	if power_up.has('action') and power_up.get('action') == "subtract":
		power_up_button.add_theme_color_override("font_color", Color.FIREBRICK)
	if power_up.has('label'):
		power_up_button.text = power_up.get('label')
		
	var end_pos_x = GameHelpers._get_random_screen_position(position.x - 200, position.x + 200)
	var end_pos_y = GameHelpers._get_random_screen_position(position.y - 200, position.y + 200)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(end_pos_x, end_pos_y), 4)
	tween.parallel().tween_property(self, "modulate:a", 0, 4)
	tween.tween_callback(queue_free)

func _exit_tree() -> void:
	print('power up removed')
