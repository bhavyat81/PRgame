class_name HUD
extends CanvasLayer

# Heads-Up Display — shows score, journey progress, lives, and on-screen buttons.

var _score_label: Label
var _distance_bar: ProgressBar
var _milestone_label: Label
var _lives_label: Label

signal jump_pressed
signal duck_pressed
signal duck_released


func _ready() -> void:
	_build_hud()


func _build_hud() -> void:
	var ctrl := Control.new()
	ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ctrl)

	# ── Score (top-left) ──────────────────────────────────────────
	_score_label = Label.new()
	_score_label.text = "Score: 0"
	_score_label.position = Vector2(20.0, 16.0)
	_score_label.add_theme_font_size_override("font_size", 28)
	_score_label.add_theme_color_override("font_color", Color.WHITE)
	ctrl.add_child(_score_label)

	# ── Distance progress bar (top-center) ───────────────────────
	var dist_vbox := VBoxContainer.new()
	dist_vbox.position = Vector2(500.0, 10.0)
	dist_vbox.custom_minimum_size = Vector2(920.0, 0.0)
	ctrl.add_child(dist_vbox)

	var journey_lbl := Label.new()
	journey_lbl.text = "Journey to PR 🍁"
	journey_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	journey_lbl.add_theme_font_size_override("font_size", 18)
	journey_lbl.add_theme_color_override("font_color", Color(1.0, 0.90, 0.50))
	dist_vbox.add_child(journey_lbl)

	_distance_bar = ProgressBar.new()
	_distance_bar.custom_minimum_size = Vector2(920.0, 26.0)
	_distance_bar.min_value = 0.0
	_distance_bar.max_value = 100.0
	_distance_bar.value = 0.0
	dist_vbox.add_child(_distance_bar)

	_milestone_label = Label.new()
	_milestone_label.text = "Express Entry Pool 🌊"
	_milestone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_milestone_label.add_theme_font_size_override("font_size", 16)
	_milestone_label.add_theme_color_override("font_color", Color(0.75, 1.0, 0.75))
	dist_vbox.add_child(_milestone_label)

	# ── Lives (top-right) ────────────────────────────────────────
	_lives_label = Label.new()
	_lives_label.text = "❤️❤️❤️"
	_lives_label.position = Vector2(1720.0, 16.0)
	_lives_label.add_theme_font_size_override("font_size", 30)
	ctrl.add_child(_lives_label)

	# ── Jump button (bottom-right) ───────────────────────────────
	var jump_btn := Button.new()
	jump_btn.text = "⬆️  JUMP"
	jump_btn.custom_minimum_size = Vector2(210.0, 100.0)
	jump_btn.position = Vector2(1680.0, 950.0)
	jump_btn.add_theme_font_size_override("font_size", 22)
	jump_btn.pressed.connect(func(): jump_pressed.emit())
	ctrl.add_child(jump_btn)

	# ── Duck button (bottom-left) ────────────────────────────────
	var duck_btn := Button.new()
	duck_btn.text = "⬇️  DUCK"
	duck_btn.custom_minimum_size = Vector2(210.0, 100.0)
	duck_btn.position = Vector2(30.0, 950.0)
	duck_btn.add_theme_font_size_override("font_size", 22)
	duck_btn.button_down.connect(func(): duck_pressed.emit())
	duck_btn.button_up.connect(func(): duck_released.emit())
	ctrl.add_child(duck_btn)


# ── Public update methods (called by Game.gd each frame) ─────────────────────

func update_score(score: int) -> void:
	if _score_label:
		_score_label.text = "Score: %d" % score


func update_distance(current: float, goal: float) -> void:
	if _distance_bar:
		_distance_bar.value = (current / goal) * 100.0
	if _milestone_label:
		_milestone_label.text = GameState.get_milestone_label()


func update_lives(lives: int) -> void:
	if _lives_label:
		var hearts := ""
		for i in range(lives):
			hearts += "❤️"
		_lives_label.text = hearts if lives > 0 else "💔"
