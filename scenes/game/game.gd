extends Node

var PowerUpPreloadScene := preload("res://scenes/power_up/power_up.tscn")

const BOSS_SCENES_DIR = "res://scenes/bosses/"

var current_boss_instance: Boss = null

func _ready() -> void:
	if LevelData.has_signal("level_change"):
		LevelData.connect("level_change", _on_level_change)
		_on_level_change(0)
	
	var power_up_timer = Timer.new()
	add_child(power_up_timer)
	
	power_up_timer.start(PowerUps.power_up_timer)
	power_up_timer.timeout.connect(add_power_up)
	
	$CanvasLayer/BossFight.connect("boss_fight_start", start_boss_phase)

func load_and_instance_boss_for_level(level_number: int) -> void:
	if is_instance_valid(current_boss_instance):
		current_boss_instance.queue_free()
		current_boss_instance = null

	if not LevelData.level_data_per_level.has(level_number):
		printerr("Error: El nivel ", level_number, " no está definido en LevelData.level_data_per_level.")
		return
	
	var boss_file_name = LevelData.level_data_per_level[level_number]["boss"]
	
	var full_boss_path = BOSS_SCENES_DIR + boss_file_name + ".tscn"
	
	if not FileAccess.file_exists(full_boss_path):
		printerr("Error Crítico: No se pudo encontrar el archivo .tscn del jefe en la ruta: ", full_boss_path)
		return

	var boss_scene = load(full_boss_path)
	
	if not boss_scene:
		printerr("Error: Falló la carga de la escena en: ", full_boss_path)
		return

	var raw_boss_node = boss_scene.instantiate()
	
	current_boss_instance = raw_boss_node as Boss
	
	if current_boss_instance == null:
		printerr("Error Crítico de Arquitectura: La escena en '", full_boss_path, "' INSTANCIA un nodo, pero este nodo NO hereda de 'class_name Boss'. Asegúrate de poner 'extends Boss' en el script del jefe específico.")
		raw_boss_node.queue_free() # Limpiamos el nodo incorrecto.
		return

	$CanvasLayer.add_child(current_boss_instance)
	
	current_boss_instance.boss_defeated.connect(_on_current_boss_defeated)
	current_boss_instance.boss_failed.connect(_on_current_boss_failed)
	
	print("Game: Jefe '", boss_file_name, "' instanciado y conectado correctamente para el nivel ", level_number)

func start_boss_phase() -> void:
	LevelData.start_boss_fight()
	
	var current_level = LevelData.level
	print("Game: Iniciando fase de jefe para nivel: ", current_level)
	
	$CanvasLayer/CounterWrapper/HBox.visible = false
	$CanvasLayer/LevelProgress.visible = false
	$CanvasLayer/NextLevel.visible = false
	$CanvasLayer/BossFight.visible = false 
	
	load_and_instance_boss_for_level(current_level)

func _on_current_boss_defeated() -> void:
	print("Game: ¡Victoria! El jefe fue derrotado.")
	
	current_boss_instance = null
	
	$CanvasLayer/CounterWrapper/HBox.visible = true
	$CanvasLayer/LevelProgress.visible = true
	$CanvasLayer/NextLevel.visible = true
	
	LevelData.end_boss_fight()
	LevelData.level_up() # Asumimos que esta función existe y sube LevelData.level

func _on_current_boss_failed() -> void:
	# Esta función se llama cuando el jefe emite 'boss_failed' (tiempo agotado).
	print("Game: Derrota... El tiempo se acabó.")
	
	# -- GESTIÓN DE JUEGO --
	# En caso de derrota, eliminamos manualmente al jefe de la pantalla.
	if is_instance_valid(current_boss_instance):
		current_boss_instance.queue_free()
		current_boss_instance = null
		
	# -- GESTIÓN DE UI --
	# Mostramos una pantalla de fallo o simplemente restauramos la UI de farmeo
	# para que el jugador pueda intentarlo de nuevo cuando quiera.
	# (Aquí podrías poner lógica de 'Game Over' más compleja).
	
	$CanvasLayer/CounterWrapper/HBox.visible = true
	$CanvasLayer/LevelProgress.visible = true
	$CanvasLayer/NextLevel.visible = true
	# Reactivamos el botón para reintentar la pelea.
	$CanvasLayer/BossFight.visible = true 
	# Opcional: reiniciar el progreso del nivel actual si quieres castigar la derrota.
	# LevelData.reset_current_level_progress()
	LevelData.end_boss_fight()
	
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
		$CanvasLayer/BossFight.text = "Fight: " + LevelData.get_level_data_per_level()
		$CanvasLayer/BossFight.visible = true
	
func _on_level_change(_level: int) -> void:
	$CanvasLayer/NextLevel.visible = false
	$CanvasLayer/BossFight.visible = false
	$CanvasLayer/CounterWrapper/HBox/Goal.text = GameHelpers._format_bytes(LevelData.goal_per_level[LevelData.level])

func _unhandled_input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion or LevelData.is_boss_fight:
		return
		
	if event is InputEventMouseButton and not event.is_echo() and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			GlobalData.bytes += 1
	
	if event is InputEventKey and not event.is_echo() and event.is_pressed():
		GlobalData.bytes += 1
		
	if LevelData.is_current_level_finished():
		$CanvasLayer/BossFight.text = "Fight: " + LevelData.get_level_data_per_level().get('boss')
		$CanvasLayer/BossFight.visible = true
