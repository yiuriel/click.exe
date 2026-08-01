extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalData.bytes_changed.connect(_on_bytes_change)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_bytes_change(bytes: float) -> void:
	text = GameHelpers._format_bytes(bytes)
