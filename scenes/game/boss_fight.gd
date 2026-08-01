extends Button

signal boss_fight_start

func _pressed() -> void:
	if LevelData.is_waiting_interaction() or LevelData.is_defeat():
		boss_fight_start.emit()
