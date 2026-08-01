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
		
	var bounds := _get_container_bounds()
	position = _clamp_to_bounds(position, bounds)
	var end_pos_x = GameHelpers._get_random_screen_position(position.x - 200, position.x + 200)
	var end_pos_y = GameHelpers._get_random_screen_position(position.y - 200, position.y + 200)
	var end_pos := _clamp_to_bounds(Vector2(end_pos_x, end_pos_y), bounds)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", end_pos, 4)
	tween.parallel().tween_property(self, "modulate:a", 0, 4)
	tween.tween_callback(queue_free)

func _get_container_bounds() -> Rect2:
	var parent: Node = get_parent()
	if parent is Control:
		var container: Control = parent as Control
		var margin_left: float = container.get_theme_constant("margin_left")
		var margin_top: float = container.get_theme_constant("margin_top")
		var margin_right: float = container.get_theme_constant("margin_right")
		var margin_bottom: float = container.get_theme_constant("margin_bottom")
		return Rect2(
			container.get_rect().position + Vector2(margin_left, margin_top),
			container.get_rect().size - Vector2(margin_left + margin_right, margin_top + margin_bottom)
		)
	return get_viewport_rect()

func _clamp_to_bounds(value: Vector2, bounds: Rect2) -> Vector2:
	var button_size: Vector2 = power_up_button.size
	var max_x: float = bounds.position.x + maxf(bounds.size.x - button_size.x, 0.0)
	var max_y: float = bounds.position.y + maxf(bounds.size.y - button_size.y, 0.0)
	return Vector2(clampf(value.x, bounds.position.x, max_x), clampf(value.y, bounds.position.y, max_y))

func _exit_tree() -> void:
	print('power up removed')
