extends Button

func _pressed() -> void:
	if LevelData.is_victory():
		LevelData.level_up()
