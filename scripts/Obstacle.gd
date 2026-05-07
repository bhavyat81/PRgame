class_name Obstacle
extends Area2D

# Obstacle types — the bureaucratic hurdles of the IRCC process.
# Ground obstacles must be jumped over; flying ones must be ducked under.

enum Type {
	ADR,               # 📄 Additional Document Request — ground
	PROCESSING_DELAY,  # ⏳ Processing Delay — wide ground
	REFUSAL,           # 🚫 Refusal Letter — flying
	MEDICALS,          # 🩺 Medicals Re-do — ground
	BIOMETRICS         # 👆 Biometrics Appointment — flying
}

const EMOJI_MAP: Dictionary = {
	Type.ADR: "📄",
	Type.PROCESSING_DELAY: "⏳",
	Type.REFUSAL: "🚫",
	Type.MEDICALS: "🩺",
	Type.BIOMETRICS: "👆",
}

const COLOR_MAP: Dictionary = {
	Type.ADR: Color(0.92, 0.72, 0.10),
	Type.PROCESSING_DELAY: Color(0.48, 0.50, 0.72),
	Type.REFUSAL: Color(0.92, 0.12, 0.12),
	Type.MEDICALS: Color(0.12, 0.78, 0.42),
	Type.BIOMETRICS: Color(0.78, 0.38, 0.92),
}

const SIZE_MAP: Dictionary = {
	Type.ADR: Vector2(62, 80),
	Type.PROCESSING_DELAY: Vector2(124, 80),
	Type.REFUSAL: Vector2(70, 60),
	Type.MEDICALS: Vector2(66, 80),
	Type.BIOMETRICS: Vector2(66, 56),
}

var obstacle_type: Type = Type.ADR
var scroll_speed: float = 400.0

signal player_hit


func setup(type: Type, speed: float) -> void:
	obstacle_type = type
	scroll_speed = speed
	_build_visuals()
	_setup_collision()
	body_entered.connect(_on_body_entered)


func _build_visuals() -> void:
	var size: Vector2 = SIZE_MAP[obstacle_type]

	var rect := ColorRect.new()
	rect.color = COLOR_MAP[obstacle_type]
	rect.size = size
	rect.position = Vector2(-size.x * 0.5, -size.y)
	add_child(rect)

	var lbl := Label.new()
	lbl.text = EMOJI_MAP[obstacle_type]
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.position = Vector2(-16.0, -size.y - 6.0)
	add_child(lbl)


func _setup_collision() -> void:
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = SIZE_MAP[obstacle_type]
	col.shape = shape
	col.position = Vector2(0.0, -SIZE_MAP[obstacle_type].y * 0.5)
	add_child(col)


func _physics_process(delta: float) -> void:
	position.x -= scroll_speed * delta
	if position.x < -200.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_hit.emit()
