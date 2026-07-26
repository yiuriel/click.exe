extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelData.connect("level_change", _on_level_change)
	_on_level_change(LevelData.level)


func _on_level_change(level: int) -> void:
	var level_data = LevelData.level_data_per_level[level]
	text = "Level: " + level_data.get('sector')
