extends Control

# Win Screen — "You got your PR Card!"
# Shown when the player covers the full pr_distance_goal.

var _rotate_angle: float = 0.0
var _maple_polygon: Polygon2D


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Canadian red background
	var bg := ColorRect.new()
	bg.color = Color(0.82, 0.05, 0.05)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# White side bands (Canadian flag style)
	for x_pos in [0.0, 1680.0]:
		var band := ColorRect.new()
		band.color = Color(1.0, 1.0, 1.0, 0.12)
		band.size = Vector2(240.0, 1080.0)
		band.position = Vector2(x_pos, 0.0)
		add_child(band)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(780.0, 0.0)
	vbox.add_theme_constant_override("separation", 22)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "🏆  CONGRATULATIONS!  🏆"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 54)
	title.add_theme_color_override("font_color", Color(1.0, 0.92, 0.0))
	vbox.add_child(title)

	var pr_label := Label.new()
	pr_label.text = "🇨🇦  You Got Your PR Card!  🇨🇦"
	pr_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pr_label.add_theme_font_size_override("font_size", 34)
	pr_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(pr_label)

	# Animated rotating maple leaf
	var leaf_holder := Control.new()
	leaf_holder.custom_minimum_size = Vector2(0.0, 130.0)
	vbox.add_child(leaf_holder)

	_maple_polygon = Polygon2D.new()
	_maple_polygon.color = Color(1.0, 1.0, 1.0)
	_maple_polygon.polygon = _make_maple_points()
	_maple_polygon.position = Vector2(390.0, 65.0)
	leaf_holder.add_child(_maple_polygon)

	# Stats
	var elapsed: float = GameState.get_elapsed_time()
	var stats := Label.new()
	stats.text = (
		"Final Score: %d\n"
		% GameState.current_score
		+ "CRS Used: %d\n" % GameState.crs_score
		+ "Time:  %.1f s" % elapsed
	)
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 26)
	stats.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(stats)

	# Buttons
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 50)
	vbox.add_child(btn_row)

	var play_again := Button.new()
	play_again.text = "🔄  Play Again"
	play_again.custom_minimum_size = Vector2(230.0, 72.0)
	play_again.add_theme_font_size_override("font_size", 23)
	play_again.pressed.connect(_on_play_again)
	btn_row.add_child(play_again)

	var quit_btn := Button.new()
	quit_btn.text = "🚪  Quit"
	quit_btn.custom_minimum_size = Vector2(180.0, 72.0)
	quit_btn.add_theme_font_size_override("font_size", 23)
	quit_btn.pressed.connect(_on_quit)
	btn_row.add_child(quit_btn)


func _make_maple_points() -> PackedVector2Array:
	# Simplified 8-pointed star to represent a maple leaf
	var pts := PackedVector2Array()
	var arms: int = 8
	var outer_r: float = 55.0
	var inner_r: float = 22.0
	for i in range(arms * 2):
		var angle: float = (PI / arms) * i - PI / 2.0
		var r: float = outer_r if i % 2 == 0 else inner_r
		pts.append(Vector2(cos(angle) * r, sin(angle) * r))
	return pts


func _process(delta: float) -> void:
	_rotate_angle += delta * 1.6
	if _maple_polygon:
		_maple_polygon.rotation = _rotate_angle


func _on_play_again() -> void:
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")


func _on_quit() -> void:
	get_tree().quit()
