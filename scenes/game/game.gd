extends Node

var PowerUpPreloadScene := preload("res://scenes/power_up/power_up.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelData.connect("level_change", _on_level_change)
	_on_level_change(0)
	
	var power_up_timer = Timer.new()
	
	add_child(power_up_timer)
	
	power_up_timer.start(PowerUps.power_up_timer)
	power_up_timer.connect("timeout", add_power_up)
	
func add_power_up() -> void:
	var power_up = PowerUps.get_power_up()
	if power_up != null and PowerUpPreloadScene.can_instantiate():
		var scene: PowerUpScene = PowerUpPreloadScene.instantiate()
		scene.add_data(power_up)
		var x = GameHelpers._get_random_screen_position(0, get_viewport().get_visible_rect().size.x)
		var y = GameHelpers._get_random_screen_position(0, get_viewport().get_visible_rect().size.y)
		scene.set_power_up_position(x, y)
		$CanvasLayer.add_child(scene)
		var powerUpButton = scene.find_child("PowerUpButton")
		powerUpButton.connect("power_up_pressed", _on_power_up_pressed)
		
		
func _on_power_up_pressed(power_up: Variant):
	GlobalData.bytes = PowerUps.handle_power_up(power_up, GlobalData.bytes)
	if LevelData.is_current_level_finished():
		$CanvasLayer/NextLevel.text = "Fight: " + LevelData.get_level_data_per_level()
		$CanvasLayer/NextLevel.visible = true
	
func _on_level_change(_level: int) -> void:
	$CanvasLayer/NextLevel.visible = false
	$CanvasLayer/CounterWrapper/Goal.text = GameHelpers._format_bytes(LevelData.goal_per_level[LevelData.level])

func _unhandled_input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion:
		return
		
	if event is InputEventMouseButton and not event.is_echo() and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			GlobalData.bytes += 1
	
	if event is InputEventKey and not event.is_echo() and event.is_pressed():
		GlobalData.bytes += 1
		
	if LevelData.is_current_level_finished():
		$CanvasLayer/NextLevel.text = "Fight: " + LevelData.get_level_data_per_level().get('boss')
		$CanvasLayer/NextLevel.visible = true
