extends Boss

var _clicks_needed: int = 10
var _current_clicks: int = 0
var _shield_broken: bool = false

func _ready() -> void:
	health = 256
	super()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.is_echo() and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_trojan_click()
	
	if event is InputEventKey and not event.is_echo() and event.is_pressed():
		_handle_trojan_click()

func _handle_trojan_click() -> void:
	if not _shield_broken:
		_current_clicks += 1
		$BossSprite.scale = Vector2(1.1, 1.1)
		get_tree().create_timer(0.05).timeout.connect(func(): $BossSprite.scale = Vector2(1, 1))
		
		if _current_clicks >= _clicks_needed:
			_shield_broken = true
			if has_node("TrojanHorseOverlay"):
				$TrojanHorseOverlay.visible = false
	else:
		take_damage(GPlayerData.get_player_click_damage())

func die() -> void:
	$BossTimer.stop()
	boss_defeated.emit()
	queue_free()
