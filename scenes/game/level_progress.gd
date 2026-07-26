extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalData.bytes_changed.connect(_on_bytes_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_bytes_changed(bytes: int) -> void:
	var new_value = bytes * 100 / LevelData.goal_per_level[LevelData.level]
	value = new_value
