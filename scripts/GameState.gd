extends Node

# GameState autoload singleton — stores CRS/CEC scores and computed difficulty.
# The immigration journey stats that affect the entire game session.
# Think of this as the applicant's Express Entry profile.

var crs_score: int = 450
var cec_score: int = 0

# Computed difficulty values (recalculated by apply_scores())
var lives: int = 2
var base_speed: float = 480.0
var obstacle_density: float = 1.0
var pr_distance_goal: float = 6200.0
var has_double_jump: bool = false   # Unlocked at CRS >= 470
var has_cec_shield: bool = false    # Canadian Experience Class bonus

# Runtime state (reset each run)
var current_score: int = 0
var distance_traveled: float = 0.0
var start_time: float = 0.0


func apply_scores() -> void:
	# Map CRS score to gameplay difficulty.
	# Higher CRS = more lives, faster speed, fewer obstacles, shorter journey.

	# Express Entry "draw chances" — more CRS = more tries
	lives = clampi(int(floor(crs_score / 200.0)), 1, 6)

	# Higher CRS = faster momentum (applicant has more going for them)
	base_speed = 300.0 + (crs_score * 0.4)

	# Higher CRS = fewer obstacles (smoother application process)
	obstacle_density = clampf(1.5 - (crs_score / 1000.0), 0.4, 1.4)

	# Higher CRS = shorter journey (faster processing, fewer hoops)
	pr_distance_goal = 8000.0 - clampf(crs_score * 4.0, 0.0, 5000.0)

	# Double-jump unlocked at CRS >= 470 (enough points for a competitive draw)
	has_double_jump = crs_score >= 470

	# Canadian Experience Class bonus: +1 life and a starting shield
	if cec_score > 0:
		lives += 1
		has_cec_shield = true
	else:
		has_cec_shield = false


func reset_runtime() -> void:
	current_score = 0
	distance_traveled = 0.0
	start_time = Time.get_ticks_msec() / 1000.0


func get_elapsed_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - start_time


func get_milestone_label() -> String:
	# Immigration milestones along the PR journey
	var pct: float = distance_traveled / pr_distance_goal
	if pct >= 1.0:
		return "PR CARD! 🏆"
	elif pct >= 0.9:
		return "Medicals Cleared ✅"
	elif pct >= 0.75:
		return "Background Check 🔍"
	elif pct >= 0.5:
		return "Documents Submitted 📁"
	elif pct >= 0.25:
		return "ITA Received! 🎉"
	else:
		return "Express Entry Pool 🌊"
