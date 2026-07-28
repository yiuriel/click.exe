extends Node

var player_bytes = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalData.bytes_changed.connect(_get_player_bytes)

func _get_player_bytes(bytes: int) -> void:
	player_bytes = bytes

func get_player_click_damage() -> int:
	return 1
