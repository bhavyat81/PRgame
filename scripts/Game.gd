extends Node2D

# Main game loop — the IRCC application process gauntlet!
# Obstacles scroll from right to left while the player stays at a fixed x position.

const GROUND_Y: float = 870.0    # y-coordinate of the ground surface
const PLAYER_X: float = 280.0    # fixed horizontal position of the player
const FLY_Y: float = 660.0       # y-coordinate for flying obstacles (duck under)
const POWERUP_Y: float = 730.0   # y-coordinate for collectible power-ups

const OBSTACLE_SCENE := preload("res://scenes/Obstacle.tscn")
const POWERUP_SCENE  := preload("res://scenes/Powerup.tscn")
const PLAYER_SCENE   := preload("res://scenes/Player.tscn")
const HUD_SCENE      := preload("res://scenes/HUD.tscn")

var scroll_speed: float = 400.0
var _spawn_timer: float = 0.0
var _spawn_interval: float = 2.0
var _game_active: bool = false
var _lives: int = 3

var _player: Player
var _hud: HUD
var _obstacles: Node2D
var _powerups: Node2D


func _ready() -> void:
	_build_world()
	_spawn_player()
	_spawn_hud()

	_lives = GameState.lives
	scroll_speed = GameState.base_speed
	# obstacle_density is seconds between spawns; higher density → shorter interval
	_spawn_interval = GameState.obstacle_density * 1.4

	_hud.update_lives(_lives)
	_game_active = true


# ── World construction ────────────────────────────────────────────────────────

func _build_world() -> void:
	# Sky gradient
	var sky := ColorRect.new()
	sky.color = Color(0.38, 0.62, 0.88)
	sky.size = Vector2(1920.0, 1080.0)
	sky.position = Vector2.ZERO
	add_child(sky)

	# Distant mountain silhouettes (parallax layer)
	_draw_mountains()

	# Ground dirt
	var ground := ColorRect.new()
	ground.color = Color(0.32, 0.22, 0.12)
	ground.size = Vector2(1920.0, 1080.0 - GROUND_Y)
	ground.position = Vector2(0.0, GROUND_Y)
	add_child(ground)

	# Grass strip at top of ground
	var grass := ColorRect.new()
	grass.color = Color(0.18, 0.62, 0.18)
	grass.size = Vector2(1920.0, 18.0)
	grass.position = Vector2(0.0, GROUND_Y - 8.0)
	add_child(grass)

	# Containers for spawned entities
	_obstacles = Node2D.new()
	_obstacles.name = "Obstacles"
	add_child(_obstacles)

	_powerups = Node2D.new()
	_powerups.name = "Powerups"
	add_child(_powerups)


func _draw_mountains() -> void:
	# Procedural mountain range using Polygon2D
	var mountains := Polygon2D.new()
	mountains.color = Color(0.28, 0.40, 0.60, 0.55)
	var pts := PackedVector2Array([
		Vector2(0.0,    GROUND_Y - 40.0),
		Vector2(0.0,    GROUND_Y - 190.0),
		Vector2(180.0,  GROUND_Y - 340.0),
		Vector2(360.0,  GROUND_Y - 170.0),
		Vector2(540.0,  GROUND_Y - 295.0),
		Vector2(720.0,  GROUND_Y - 150.0),
		Vector2(900.0,  GROUND_Y - 310.0),
		Vector2(1080.0, GROUND_Y - 185.0),
		Vector2(1260.0, GROUND_Y - 270.0),
		Vector2(1440.0, GROUND_Y - 140.0),
		Vector2(1620.0, GROUND_Y - 255.0),
		Vector2(1800.0, GROUND_Y - 130.0),
		Vector2(1920.0, GROUND_Y - 200.0),
		Vector2(1920.0, GROUND_Y - 40.0),
	])
	mountains.polygon = pts
	add_child(mountains)


func _spawn_player() -> void:
	_player = PLAYER_SCENE.instantiate() as Player
	_player.position = Vector2(PLAYER_X, GROUND_Y)
	_player.hit_obstacle.connect(_on_player_lost_life)
	add_child(_player)


func _spawn_hud() -> void:
	_hud = HUD_SCENE.instantiate() as HUD
	_hud.jump_pressed.connect(_on_jump_pressed)
	_hud.duck_pressed.connect(_on_duck_pressed)
	_hud.duck_released.connect(_on_duck_released)
	add_child(_hud)


# ── Main loop ─────────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if not _game_active:
		return

	# Increment distance and score
	GameState.distance_traveled += scroll_speed * delta
	GameState.current_score += int(scroll_speed * delta * 0.1)

	_hud.update_score(GameState.current_score)
	_hud.update_distance(GameState.distance_traveled, GameState.pr_distance_goal)

	# Win condition — reached the PR card!
	if GameState.distance_traveled >= GameState.pr_distance_goal:
		_win()
		return

	# Obstacle / powerup spawn timing
	_spawn_timer += delta
	if _spawn_timer >= _spawn_interval:
		_spawn_timer = 0.0
		_spawn_obstacle()
		if randf() < 0.30:
			_spawn_powerup()

	# Gradually increase speed as the journey gets harder
	scroll_speed = minf(scroll_speed + 6.0 * delta, GameState.base_speed * 2.0)


# ── Spawning ──────────────────────────────────────────────────────────────────

func _spawn_obstacle() -> void:
	var obs := OBSTACLE_SCENE.instantiate() as Obstacle

	# Pick a random obstacle type
	var all_types: Array = [
		Obstacle.Type.ADR,
		Obstacle.Type.PROCESSING_DELAY,
		Obstacle.Type.REFUSAL,
		Obstacle.Type.MEDICALS,
		Obstacle.Type.BIOMETRICS,
	]
	var t: Obstacle.Type = all_types[randi() % all_types.size()]

	# Flying obstacles spawn high — player must duck under them
	var y: float = FLY_Y if (t == Obstacle.Type.REFUSAL or t == Obstacle.Type.BIOMETRICS) else GROUND_Y

	obs.position = Vector2(2050.0, y)
	_obstacles.add_child(obs)
	obs.setup(t, scroll_speed)
	obs.player_hit.connect(_on_obstacle_hit)


func _spawn_powerup() -> void:
	var pow := POWERUP_SCENE.instantiate() as Powerup

	# Weighted random: NOC coins most common, PNP nomination rare
	var roll: float = randf()
	var t: Powerup.Type
	if roll < 0.50:
		t = Powerup.Type.NOC_COIN
	elif roll < 0.74:
		t = Powerup.Type.CRS_BOOST
	elif roll < 0.90:
		t = Powerup.Type.LMIA_SHIELD
	else:
		t = Powerup.Type.PNP_NOMINATION  # 10% — rare government gift!

	pow.position = Vector2(2050.0, POWERUP_Y)
	_powerups.add_child(pow)
	pow.setup(t, scroll_speed)
	pow.collected.connect(_on_powerup_collected)


# ── Signal handlers ───────────────────────────────────────────────────────────

func _on_obstacle_hit() -> void:
	if _player:
		_player.take_hit()


func _on_player_lost_life() -> void:
	_lives -= 1
	_hud.update_lives(_lives)
	if _lives <= 0:
		_game_over()


func _on_powerup_collected(type: int) -> void:
	match type:
		Powerup.Type.NOC_COIN:
			# Small but steady — like adding a NOC code to your profile
			GameState.current_score += 50
		Powerup.Type.CRS_BOOST:
			# Temporary speed boost — like getting a CRS bump from a new job
			GameState.current_score += 100
			scroll_speed *= 1.25
			if _player:
				_player.is_invincible = true
				_player.invincible_timer = 3.0
		Powerup.Type.PNP_NOMINATION:
			# Huge points — Provincial Nominee Program is a game-changer!
			GameState.current_score += 600
		Powerup.Type.LMIA_SHIELD:
			# LMIA job offer absorbs one hit
			if _player:
				_player.has_shield = true
				_player._show_shield()


func _on_jump_pressed() -> void:
	if _player:
		_player.jump_from_button()


func _on_duck_pressed() -> void:
	if _player:
		_player.duck_from_button(true)


func _on_duck_released() -> void:
	if _player:
		_player.duck_from_button(false)


# ── Scene transitions ─────────────────────────────────────────────────────────

func _win() -> void:
	_game_active = false
	get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")


func _game_over() -> void:
	_game_active = false
	get_tree().change_scene_to_file("res://scenes/GameOverScreen.tscn")
