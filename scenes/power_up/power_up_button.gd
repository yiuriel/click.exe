extends Button

signal power_up_pressed(power_up)

@onready var power_up_scene: PowerUpScene = get_parent() as PowerUpScene

func _pressed() -> void:
	power_up_pressed.emit(power_up_scene.power_up)
	queue_free()
