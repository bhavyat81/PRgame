extends Control

# Start Screen — where the applicant enters their CRS / CEC score
# before embarking on the PR Journey.

var crs_input: LineEdit
var cec_input: LineEdit


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Dark blue background (government portal vibes)
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.08, 0.22)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Decorative top stripe (Canadian red)
	var stripe := ColorRect.new()
	stripe.color = Color(0.85, 0.06, 0.06)
	stripe.size = Vector2(1920, 12)
	stripe.position = Vector2.ZERO
	add_child(stripe)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(620, 0)
	vbox.add_theme_constant_override("separation", 18)
	center.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "🍁 PR Journey: The Endless Runner 🍁"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Navigate the IRCC obstacle course to your PR Card!"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.75, 0.88, 1.0))
	vbox.add_child(subtitle)

	_add_spacer(vbox, 16)

	# CRS input
	var crs_label := Label.new()
	crs_label.text = "Your CRS Score  (0 – 1200):"
	crs_label.add_theme_font_size_override("font_size", 20)
	crs_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(crs_label)

	crs_input = LineEdit.new()
	crs_input.placeholder_text = "e.g. 450   (default if empty)"
	crs_input.custom_minimum_size = Vector2(0, 54)
	crs_input.add_theme_font_size_override("font_size", 20)
	vbox.add_child(crs_input)

	_add_spacer(vbox, 6)

	# CEC input
	var cec_label := Label.new()
	cec_label.text = "Your CEC Score  (optional, 0 – 1200):"
	cec_label.add_theme_font_size_override("font_size", 20)
	cec_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(cec_label)

	cec_input = LineEdit.new()
	cec_input.placeholder_text = "Leave blank if not applicable"
	cec_input.custom_minimum_size = Vector2(0, 54)
	cec_input.add_theme_font_size_override("font_size", 20)
	vbox.add_child(cec_input)

	_add_spacer(vbox, 14)

	# Start button
	var start_btn := Button.new()
	start_btn.text = "🚀  Start Your PR Journey"
	start_btn.custom_minimum_size = Vector2(0, 66)
	start_btn.add_theme_font_size_override("font_size", 26)
	start_btn.pressed.connect(_on_start_pressed)
	vbox.add_child(start_btn)

	_add_spacer(vbox, 10)

	# Instructions
	var instructions := Label.new()
	instructions.text = (
		"Controls:\n"
		+ "  ⬆️  Tap screen / Space / Up Arrow  =  Jump\n"
		+ "  ⬇️  Swipe down / Down Arrow  =  Duck\n"
		+ "  On-screen JUMP / DUCK buttons available in-game\n\n"
		+ "Higher CRS → faster speed, fewer obstacles, shorter journey 🏃"
	)
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.add_theme_font_size_override("font_size", 16)
	instructions.add_theme_color_override("font_color", Color(0.65, 0.82, 1.0))
	vbox.add_child(instructions)


func _add_spacer(parent: VBoxContainer, height: int) -> void:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, height)
	parent.add_child(s)


func _on_start_pressed() -> void:
	# Validate and store scores; default CRS to 450 if blank/invalid
	var crs_val: String = crs_input.text.strip_edges()
	var cec_val: String = cec_input.text.strip_edges()

	GameState.crs_score = 450
	if crs_val.is_valid_int():
		GameState.crs_score = clampi(int(crs_val), 0, 1200)

	GameState.cec_score = 0
	if cec_val.is_valid_int():
		GameState.cec_score = clampi(int(cec_val), 0, 1200)

	GameState.apply_scores()
	GameState.reset_runtime()

	get_tree().change_scene_to_file("res://scenes/Game.tscn")
