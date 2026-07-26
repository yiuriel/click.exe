class_name Boss extends Node2D

var health: float = 1024

func _ready() -> void:
	$HealthBar.max_value = health
	$HealthBar.value = health
	$BossTimer.start(30)
	center_sprite()
	_update_health_label()

func take_damage(amount: float) -> void:
	health -= amount
	$HealthBar.value = health
	_update_health_label()
	if health <= 0:
		die()

func die() -> void:
	pass

func _update_health_label() -> void:
	$HealthBar/HpLabel.text = GameHelpers._format_bytes(health)

func center_sprite() -> void:
	var viewport = get_viewport()
	if viewport:
		$BossSprite.position = viewport.get_visible_rect().size / 2
