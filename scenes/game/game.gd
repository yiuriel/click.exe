extends Node

var PowerUpPreloadScene := preload("res://scenes/power_up/power_up.tscn")

const BOSS_SCENES_DIR = "res://scenes/bosses/"

var current_boss_instance: Boss = null

@onready var ui_canvas_layer: CanvasLayer = find_child("CanvasLayer", true, false)
@onready var boss_fight_button: Button = find_child("BossFight", true, false)
@onready var level_progress_bar: ProgressBar = find_child("LevelProgress", true, false)
@onready var next_level_button: Button = find_child("NextLevel", true, false)
@onready var goal_label: Label = find_child("Goal", true, false)
@onready var boss_positioner: Control = find_child("BossPositioner", true, false)
@onready var power_ups_container: MarginContainer = find_child("PowerUpsContainer", true, false)

func _ready() -> void:
	LevelData.level_change.connect(_on_level_change)
	LevelData.game_state_changed.connect(_on_game_state_changed)
	GlobalData.bytes_changed.connect(_on_bytes_changed)
	_on_level_change(0)
	
	var power_up_timer = Timer.new()
	add_child(power_up_timer)
	
	power_up_timer.start(PowerUps.power_up_timer)
	power_up_timer.timeout.connect(add_power_up)
	
	boss_fight_button.connect("boss_fight_start", start_boss_phase)

func load_and_instance_boss_for_level(level_number: int) -> void:
	if is_instance_valid(current_boss_instance):
		current_boss_instance.queue_free()
		current_boss_instance = null

	if not LevelData.level_data_per_level.has(level_number):
		printerr("Error: El nivel ", level_number, " no está definido en LevelData.level_data_per_level.")
		return
	
	var boss_file_name: String = LevelData.level_data_per_level[level_number]["boss"]
	
	var full_boss_path: String = BOSS_SCENES_DIR + boss_file_name + ".tscn"
	
	if not FileAccess.file_exists(full_boss_path):
		printerr("Error Crítico: No se pudo encontrar el archivo .tscn del jefe en la ruta: ", full_boss_path)
		return

	var boss_scene: PackedScene = load(full_boss_path)
	
	if not boss_scene:
		printerr("Error: Falló la carga de la escena en: ", full_boss_path)
		return

	var raw_boss_node: Node = boss_scene.instantiate()
	
	current_boss_instance = raw_boss_node as Boss
	
	if current_boss_instance == null:
		printerr("Error Crítico de Arquitectura: La escena en '", full_boss_path, "' INSTANCIA un nodo, pero este nodo NO hereda de 'class_name Boss'. Asegúrate de poner 'extends Boss' en el script del jefe específico.")
		raw_boss_node.queue_free() # Limpiamos el nodo incorrecto.
		return

	boss_positioner.visible = true
	boss_positioner.add_child(current_boss_instance)
	
	current_boss_instance.boss_defeated.connect(_on_current_boss_defeated)
	current_boss_instance.boss_failed.connect(_on_current_boss_failed)
	
	print("Game: Jefe '", boss_file_name, "' instanciado y conectado correctamente para el nivel ", level_number)

func start_boss_phase() -> void:
	LevelData.start_boss_fight()
	
	var current_level: int = LevelData.level
	print("Game: Iniciando fase de jefe para nivel: ", current_level)
	
	load_and_instance_boss_for_level(current_level)

func _on_current_boss_defeated() -> void:
	print("Game: ¡Victoria! El jefe fue derrotado.")
	
	current_boss_instance = null
	LevelData.boss_fight_won()

func _on_current_boss_failed() -> void:
	print("Game: Derrota... El tiempo se acabó.")
	
	if is_instance_valid(current_boss_instance):
		current_boss_instance.queue_free()
		current_boss_instance = null
	LevelData.boss_fight_lost()
	
func add_power_up() -> void:
	var power_up = PowerUps.get_power_up()
	if power_up != null and PowerUpPreloadScene.can_instantiate():
		var scene: PowerUpScene = PowerUpPreloadScene.instantiate()
		scene.add_data(power_up)
		var bounds: Rect2 = power_ups_container.get_rect()
		var x: float = GameHelpers._get_random_screen_position(bounds.position.x, bounds.size.x)
		var y: float = GameHelpers._get_random_screen_position(bounds.position.y, bounds.size.y)
		scene.set_power_up_position(x, y)
		power_ups_container.add_child(scene)
		var power_up_button: Button = scene.find_child("PowerUpButton", true, false)
		power_up_button.connect("power_up_pressed", _on_power_up_pressed)
		
		
func _on_power_up_pressed(power_up: Variant):
	GlobalData.bytes = PowerUps.handle_power_up(power_up, GlobalData.bytes)
	
func _on_bytes_changed(_bytes: int) -> void:
	if LevelData.is_game_level() and LevelData.is_current_level_finished():
		LevelData.game_state = LevelData.GameState.WAITING_FOR_INTERACTION
	else:
		_update_ui_visibility()
	
func _on_game_state_changed(_new_state: LevelData.GameState) -> void:
	_update_ui_visibility()
	
func _update_ui_visibility() -> void:
	boss_positioner.visible = LevelData.game_state == LevelData.GameState.BOSS_LEVEL
	level_progress_bar.visible = LevelData.game_state != LevelData.GameState.BOSS_LEVEL
	next_level_button.visible = LevelData.is_victory()
	boss_fight_button.visible = LevelData.is_waiting_interaction() or LevelData.is_defeat()
	
func _on_level_change(_level: int) -> void:
	goal_label.text = GameHelpers._format_bytes(LevelData.goal_per_level[LevelData.level])
	boss_fight_button.text = "Fight: " + LevelData.get_level_data_per_level().get('boss')
	_update_ui_visibility()

func _unhandled_input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion or not (LevelData.is_game_level() or LevelData.is_waiting_interaction()):
		return
		
	if event is InputEventMouseButton and not event.is_echo() and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			GlobalData.bytes += 1
	
	if event is InputEventKey and not event.is_echo() and event.is_pressed():
		GlobalData.bytes += 1
