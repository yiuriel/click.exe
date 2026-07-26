extends Control

@export var anim_duration: float = 0.08
@export var move_distance: float = 35.0
@export var font_size: int = 30
@export var custom_font: Font

var current_bytes: float = 0.0
var target_bytes: float = 0.0
var current_label: Label = null
var is_animating: bool = false

func _ready() -> void:
	# 1. Inicializar el primer texto con el valor actual del GlobalData
	current_bytes = GlobalData.bytes
	target_bytes = GlobalData.bytes
	
	current_label = _create_number_label(current_bytes)
	add_child(current_label)
	
	# 2. CONECTAR LA SEÑAL: Cambia "bytes_changed" por el nombre real de tu señal
	GlobalData.bytes_changed.connect(_on_global_bytes_changed)

# Esta función se ejecutará automáticamente cada vez que GlobalData emita la señal
func _on_global_bytes_changed(new_amount: float) -> void:
	target_bytes = new_amount
	
	if not is_animating:
		_process_next_animation()

func _process_next_animation() -> void:
	if current_bytes == target_bytes:
		is_animating = false
		return
		
	is_animating = true
	
	# 1. Animamos el número VIEJO
	var old_label = current_label
	if is_instance_valid(old_label):
		var old_tween = create_tween().set_parallel(true)
		old_tween.tween_property(old_label, "position:y", -move_distance, anim_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		old_tween.tween_property(old_label, "modulate:a", 0.0, anim_duration)

		# .chain() espera a que terminen las animaciones de arriba, y luego ejecuta el callback sobre el label viejo
		old_tween.chain().tween_callback(old_label.queue_free)
	
	# 2. Capturamos el valor más reciente
	current_bytes = target_bytes 
	
	# 3. Animamos el número NUEVO
	var new_label = _create_number_label(current_bytes)
	add_child(new_label)
	
	new_label.position.y = move_distance
	new_label.modulate.a = 0.0
	
	var new_tween = create_tween().set_parallel(true)
	new_tween.tween_property(new_label, "position:y", 0.0, anim_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	new_tween.tween_property(new_label, "modulate:a", 1.0, anim_duration)
	
	current_label = new_label
	
	await new_tween.finished
	_process_next_animation()

func _create_number_label(bytes: float) -> Label:
	var lbl = Label.new()
	lbl.text = GameHelpers._format_bytes(bytes)
	lbl.add_theme_font_size_override("font_size", font_size)
	if custom_font:
		lbl.add_theme_font_override("font", custom_font)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.anchors_preset = Control.PRESET_CENTER
	return lbl
