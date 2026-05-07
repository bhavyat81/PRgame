extends Control

# Game Over Screen — "Application Refused".
# Shown when the player runs out of lives.


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Dark background — the IRCC refusal letter colour scheme
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.04, 0.10)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(760.0, 0.0)
	vbox.add_theme_constant_override("separation", 22)
	center.add_child(vbox)

	var refused_lbl := Label.new()
	refused_lbl.text = "❌  Application Refused"
	refused_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	refused_lbl.add_theme_font_size_override("font_size", 52)
	refused_lbl.add_theme_color_override("font_color", Color(1.0, 0.18, 0.18))
	vbox.add_child(refused_lbl)

	var ircc_lbl := Label.new()
	ircc_lbl.text = (
		"We regret to inform you that your Express Entry profile\n"
		+ "did not successfully complete the PR Journey."
	)
	ircc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ircc_lbl.add_theme_font_size_override("font_size", 20)
	ircc_lbl.add_theme_color_override("font_color", Color(0.78, 0.78, 0.78))
	vbox.add_child(ircc_lbl)

	# Stats
	var pct: float = (GameState.distance_traveled / GameState.pr_distance_goal) * 100.0
	var milestone: String = GameState.get_milestone_label()
	var stats_lbl := Label.new()
	stats_lbl.text = (
		"Distance:  %.0f / %.0f px  (%.1f%%)\n" % [
			GameState.distance_traveled, GameState.pr_distance_goal, pct
		]
		+ "Last Milestone:  %s\n" % milestone
		+ "Final Score:  %d\n" % GameState.current_score
		+ "CRS Score:  %d" % GameState.crs_score
	)
	stats_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_lbl.add_theme_font_size_override("font_size", 22)
	stats_lbl.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(stats_lbl)

	var encourage_lbl := Label.new()
	encourage_lbl.text = "💪  Improve your CRS and try again!"
	encourage_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	encourage_lbl.add_theme_font_size_override("font_size", 24)
	encourage_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.28))
	vbox.add_child(encourage_lbl)

	# Buttons
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 50)
	vbox.add_child(btn_row)

	var try_again := Button.new()
	try_again.text = "🔄  Try Again"
	try_again.custom_minimum_size = Vector2(230.0, 72.0)
	try_again.add_theme_font_size_override("font_size", 23)
	try_again.pressed.connect(_on_try_again)
	btn_row.add_child(try_again)

	var change_score := Button.new()
	change_score.text = "✏️  Change Score"
	change_score.custom_minimum_size = Vector2(230.0, 72.0)
	change_score.add_theme_font_size_override("font_size", 23)
	change_score.pressed.connect(_on_change_score)
	btn_row.add_child(change_score)


func _on_try_again() -> void:
	# Keep same CRS/CEC — just reset the run
	GameState.reset_runtime()
	GameState.apply_scores()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_change_score() -> void:
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")
