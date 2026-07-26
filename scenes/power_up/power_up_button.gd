extends Button

signal power_up_pressed(power_up)

func _pressed() -> void:
	power_up_pressed.emit($"..".power_up)
	queue_free()
	
