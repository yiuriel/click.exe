extends Node2D

class_name Boss

signal boss_defeated
signal boss_failed

var health: float = 1024
var bar_stylebox: StyleBoxFlat

@onready var health_bar: ProgressBar = find_child("HealthBar", true, false)
@onready var timer_bar: ProgressBar = find_child("TimerBar", true, false)
@onready var boss_timer: Timer = find_child("BossTimer", true, false)
@onready var timer_label: Label = find_child("TimerLabel", true, false)
@onready var hp_label: Label = find_child("HpLabel", true, false)
@onready var boss_sprite: Sprite2D = find_child("BossSprite", true, false)

func _ready() -> void:
	health_bar.max_value = health
	health_bar.value = health
	_update_health_label()
	
	var original_style = timer_bar.get_theme_stylebox("fill")
	bar_stylebox = original_style.duplicate() as StyleBoxFlat
	timer_bar.add_theme_stylebox_override("fill", bar_stylebox)
	
	boss_timer.timeout.connect(_on_boss_timer_timeout)
	
	start_boss_timer(30)

func start_boss_timer(duration: float) -> void:
	timer_bar.max_value = 100.0
	timer_bar.value = 100.0
	bar_stylebox.bg_color = Color("#4ad15e")
	
	boss_timer.start(duration)
	
	var tween = create_tween()
	# Tell the tween that the following animations should run simultaneously
	tween.parallel().tween_property(timer_bar, "value", 0.0, duration)
	tween.parallel().tween_method(check_bar_color, 100.0, 0.0, duration)

func check_bar_color(current_value: float) -> void:
	if current_value > 66:
		bar_stylebox.bg_color = Color("#4ad15e")
	elif current_value > 33:
		bar_stylebox.bg_color = Color("#f6d12a")
	else:
		bar_stylebox.bg_color = Color("#f6354d")
		
	var seconds_left = ceil((current_value / 100.0) * boss_timer.wait_time)
	timer_label.text = str(int(seconds_left))

func take_damage(amount: float) -> void:
	if health <= 0 or boss_timer.is_stopped():
		return
		
	health -= amount
	health_bar.value = health
	_update_health_label()
	
	if health <= 0:
		health = 0
		health_bar.value = 0
		_update_health_label()
		die()

func die() -> void:
	boss_timer.stop()
	print("Boss base: Muriendo...")
	boss_defeated.emit()
	queue_free()

func _on_boss_timer_timeout() -> void:
	timer_label.text = "0"
	print("Boss base: Tiempo agotado...")
	boss_failed.emit()

func _update_health_label() -> void:
	if hp_label:
		hp_label.text = GameHelpers._format_bytes(health)
