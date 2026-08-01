extends RichTextLabel

const PROMPT = "C:\\> "

var max_visible_lines: int = 15

func _ready() -> void:
	_calculate_max_lines()
	get_viewport().size_changed.connect(_calculate_max_lines)
	
	append_text(PROMPT)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		
		# 1. Detect Enter / Return
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			append_text("\n" + PROMPT)
			_check_and_clear_if_needed()
			return
			
		# 2. Detect Spacebar
		if event.keycode == KEY_SPACE:
			append_text(" ")
			return
			
		# 3. Ignore non-printable control keys
		if event.keycode in [KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_CAPSLOCK, KEY_ESCAPE, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_BACKSPACE, KEY_TAB]:
			return

		# 4. Capture real character using unicode
		if event.unicode != 0:
			var real_char: String = char(event.unicode)
			append_text(real_char.to_lower())
			_check_and_clear_if_needed()

func _check_and_clear_if_needed() -> void:
	if get_line_count() > max_visible_lines:
		clear()
		append_text(PROMPT)

func _calculate_max_lines() -> void:
	var box_height: float = size.y
	var font: Font = get_theme_font("normal_font")
	var font_size: int = get_theme_font_size("normal_font_size")
	
	var line_height: float = font.get_height(font_size)
	var separation: float = get_theme_constant("line_separation")
	var total_line_height: float = line_height + separation
	
	if total_line_height > 0:
		max_visible_lines = max(1, int(box_height / total_line_height))
