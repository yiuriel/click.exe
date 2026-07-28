extends Node2D

class_name Boss

signal boss_defeated
signal boss_failed

var health: float = 1024
var bar_stylebox: StyleBoxFlat

func _ready() -> void:
	$HealthBar.max_value = health
	$HealthBar.value = health
	_update_health_label()
	
	center_sprite()
	center_health_bar()
	
	var original_style = $TimerBar.get_theme_stylebox("fill")
	bar_stylebox = original_style.duplicate() as StyleBoxFlat
	$TimerBar.add_theme_stylebox_override("fill", bar_stylebox)
	
	$BossTimer.timeout.connect(_on_boss_timer_timeout)
	
	start_boss_timer(30)

func start_boss_timer(duration: float) -> void:
	$TimerBar.max_value = 100.0
	$TimerBar.value = 100.0
	bar_stylebox.bg_color = Color("#4ad15e")
	
	$BossTimer.start(duration)
	
	var tween = create_tween()
	# Tell the tween that the following animations should run simultaneously
	tween.parallel().tween_property($TimerBar, "value", 0.0, duration)
	tween.parallel().tween_method(check_bar_color, 100.0, 0.0, duration)

func check_bar_color(current_value: float) -> void:
	if current_value > 66:
		bar_stylebox.bg_color = Color("#4ad15e")
	elif current_value > 33:
		bar_stylebox.bg_color = Color("#f6d12a")
	else:
		bar_stylebox.bg_color = Color("#f6354d")
		
	var seconds_left = ceil((current_value / 100.0) * $BossTimer.wait_time)
	$TimerBar/TimerLabel.text = str(int(seconds_left))

func take_damage(amount: float) -> void:
	if health <= 0 or $BossTimer.is_stopped():
		return
		
	health -= amount
	$HealthBar.value = health
	_update_health_label()
	
	if health <= 0:
		health = 0
		$HealthBar.value = 0
		_update_health_label()
		die()

func die() -> void:
	$BossTimer.stop()
	print("Boss base: Muriendo...")
	boss_defeated.emit()
	queue_free()

func _on_boss_timer_timeout() -> void:
	$TimerBar/TimerLabel.text = "0"
	print("Boss base: Tiempo agotado...")
	boss_failed.emit()

func _update_health_label() -> void:
	if has_node("HealthBar/HpLabel"):
		$HealthBar/HpLabel.text = GameHelpers._format_bytes(health)

func center_sprite() -> void:
	var viewport = get_viewport()
	if viewport and has_node("BossSprite"):
		$BossSprite.position = viewport.get_visible_rect().size / 2
		
func center_health_bar() -> void:
	var viewport = get_viewport()
	if viewport and has_node("HealthBar"):
		$HealthBar.position.x = (viewport.get_visible_rect().size / 2).x - $HealthBar.size.x / 2
