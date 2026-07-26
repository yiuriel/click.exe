extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelData.connect("level_change", _on_level_change)


func _on_level_change(level: int) -> void:
	text = "Level: " + str(level)
