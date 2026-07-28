extends Node2D

class_name Boss

signal boss_defeated
signal boss_failed

var health: float = 1024

func _ready() -> void:
	$HealthBar.max_value = health
	$HealthBar.value = health
	_update_health_label()
	
	center_sprite()
	center_health_bar()
	
	$BossTimer.timeout.connect(_on_boss_timer_timeout)
	
	$BossTimer.start(30)

func take_damage(amount: float) -> void:
	if health <= 0 or $BossTimer.is_stopped():
		return
		
	health -= amount
	$HealthBar.value = health
	_update_health_label()
	
	if health <= 0:
		health = 0 # Asegurar que no sea negativa para la UI
		$HealthBar.value = 0
		_update_health_label()
		die()

func die() -> void:
	$BossTimer.stop()
	
	print("Boss base: Muriendo...")
	
	boss_defeated.emit()
	
	queue_free()

func _on_boss_timer_timeout() -> void:
	print("Boss base: Tiempo agotado...")
	
	boss_failed.emit()
	
	# Nota: Normalmente no hacemos queue_free() aquí inmediatamente para 
	# permitir que el GameManager muestre una pantalla de "Game Over".
	# El GameManager se encargará de limpiar este nodo.

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
		$HealthBar.position.y += $HealthBar.size.y
