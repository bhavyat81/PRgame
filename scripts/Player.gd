class_name Player
extends CharacterBody2D

# Player character — the applicant navigating the IRCC process.
# Supports jump, double-jump (CRS >= 470), and duck mechanics.
# Touch gestures: tap = jump, swipe-down = duck.

const GRAVITY: float = 1800.0
const JUMP_VELOCITY: float = -760.0
const STAND_HEIGHT: float = 80.0
const DUCK_HEIGHT: float = 38.0

var jump_count: int = 0
var max_jumps: int = 1       # 2 if CRS >= 470
var is_ducking: bool = false

var is_invincible: bool = false
var invincible_timer: float = 0.0
var has_shield: bool = false

# Touch gesture tracking
var _touch_start: Vector2 = Vector2.ZERO
var _touch_active: bool = false
var _duck_button_held: bool = false

# Child nodes (built procedurally in _ready)
var _collision_shape: CollisionShape2D
var _body_rect: ColorRect
var _emoji_label: Label
var _shield_rect: ColorRect

signal hit_obstacle


func _ready() -> void:
	# Build player visuals procedurally — a little blue applicant 🧑
	_collision_shape = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(56, STAND_HEIGHT)
	_collision_shape.shape = shape
	add_child(_collision_shape)

	_body_rect = ColorRect.new()
	_body_rect.color = Color(0.18, 0.55, 0.95)
	_body_rect.size = Vector2(56, STAND_HEIGHT)
	_body_rect.position = Vector2(-28.0, -STAND_HEIGHT)
	add_child(_body_rect)

	_emoji_label = Label.new()
	_emoji_label.text = "🧑"
	_emoji_label.add_theme_font_size_override("font_size", 42)
	_emoji_label.position = Vector2(-22.0, -STAND_HEIGHT - 6.0)
	add_child(_emoji_label)

	max_jumps = 2 if GameState.has_double_jump else 1

	if GameState.has_cec_shield:
		has_shield = true
		_show_shield()


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		jump_count = 0

	# Keyboard / action jump
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		_do_jump()

	# Duck from keyboard
	var want_duck: bool = (Input.is_action_pressed("duck") or _duck_button_held) and is_on_floor()
	_set_duck(want_duck)

	move_and_slide()

	# Invincibility flash countdown
	if is_invincible:
		invincible_timer -= delta
		modulate.a = 0.5 + 0.5 * sin(invincible_timer * 30.0)
		if invincible_timer <= 0.0:
			is_invincible = false
			modulate = Color.WHITE


func _unhandled_input(event: InputEvent) -> void:
	# Touch gesture: tap = jump, swipe-down = duck
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			_touch_start = touch_event.position
			_touch_active = true
		else:
			# Finger lifted — end duck if it was a swipe-down
			if _duck_button_held:
				_duck_button_held = false
			if _touch_active:
				var diff: Vector2 = touch_event.position - _touch_start
				# Treat as a tap if no significant vertical movement
				if abs(diff.y) < 80.0 and abs(diff.x) < 80.0:
					jump_from_button()
				_touch_active = false
	elif event is InputEventScreenDrag and _touch_active:
		var drag_event := event as InputEventScreenDrag
		var diff: Vector2 = drag_event.position - _touch_start
		if diff.y > 90.0:
			# Swipe-down detected → duck
			_duck_button_held = true
			_touch_active = false


func _do_jump() -> void:
	velocity.y = JUMP_VELOCITY
	jump_count += 1


func _set_duck(ducking: bool) -> void:
	if ducking == is_ducking:
		return
	is_ducking = ducking
	var h: float = DUCK_HEIGHT if ducking else STAND_HEIGHT
	(_collision_shape.shape as RectangleShape2D).size = Vector2(56.0, h)
	_body_rect.size = Vector2(56.0, h)
	_body_rect.position = Vector2(-28.0, -h)
	_emoji_label.visible = not ducking


func take_hit() -> void:
	if is_invincible:
		return
	if has_shield:
		has_shield = false
		_remove_shield()
		_start_invincibility()
		return
	hit_obstacle.emit()
	_start_invincibility()


func _start_invincibility() -> void:
	is_invincible = true
	invincible_timer = 0.8


func _show_shield() -> void:
	_shield_rect = ColorRect.new()
	_shield_rect.color = Color(0.0, 1.0, 0.78, 0.28)
	_shield_rect.size = Vector2(76.0, 90.0)
	_shield_rect.position = Vector2(-38.0, -STAND_HEIGHT - 4.0)
	add_child(_shield_rect)


func _remove_shield() -> void:
	if _shield_rect:
		_shield_rect.queue_free()
		_shield_rect = null


# Called by HUD on-screen Jump button press
func jump_from_button() -> void:
	if jump_count < max_jumps:
		_do_jump()


# Called by HUD on-screen Duck button press/release
func duck_from_button(pressed: bool) -> void:
	_duck_button_held = pressed
