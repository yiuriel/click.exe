extends Boss

var _clicks_needed: int = 10
var _current_clicks: int = 0
var _shield_broken: bool = false
var _shield_timer: Timer = Timer.new()
var _initial_scale: Vector2

@onready var trojan_horse_overlay: Node2D = find_child("TrojanHorseOverlay", true, false)

func _ready() -> void:
	health = 256
	_initial_scale = boss_sprite.scale
	_shield_timer.one_shot = true
	_shield_timer.timeout.connect(_restart_shield)
	add_child(_shield_timer)
	super()

func _restart_shield() -> void:
	_current_clicks = 0
	_shield_broken = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.is_echo() and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_trojan_click()
	
	if event is InputEventKey and not event.is_echo() and event.is_pressed():
		_handle_trojan_click()

func _handle_trojan_click() -> void:
	if not _shield_broken:
		_current_clicks += 1
		boss_sprite.scale = Vector2(_initial_scale * 1.1)
		get_tree().create_timer(0.05).timeout.connect(func(): boss_sprite.scale = _initial_scale)
		
		if _current_clicks >= _clicks_needed:
			_shield_broken = true
			_shield_timer.start(5)
			if trojan_horse_overlay:
				trojan_horse_overlay.visible = false
	else:
		take_damage(GPlayerData.get_player_click_damage())

func die() -> void:
	boss_timer.stop()
	boss_defeated.emit()
	queue_free()
