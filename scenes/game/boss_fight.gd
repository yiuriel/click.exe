extends Button

signal boss_fight_start

# Called when the node enters the scene tree for the first time.
func _pressed() -> void:
	boss_fight_start.emit()
