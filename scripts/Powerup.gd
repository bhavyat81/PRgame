class_name Powerup
extends Area2D

# Power-up types — the immigration advantages that help the applicant.

enum Type {
	NOC_COIN,       # 🍁 NOC Coin — +50 points
	CRS_BOOST,      # 📈 CRS Boost — 3 s speed boost + invincibility
	PNP_NOMINATION, # 🎓 PNP Nomination — +600 points (rare)
	LMIA_SHIELD     # 💼 LMIA Job Offer — absorbs 1 hit
}

const EMOJI_MAP: Dictionary = {
	Type.NOC_COIN: "🍁",
	Type.CRS_BOOST: "📈",
	Type.PNP_NOMINATION: "🎓",
	Type.LMIA_SHIELD: "💼",
}

const COLOR_MAP: Dictionary = {
	Type.NOC_COIN: Color(1.0, 0.80, 0.0),
	Type.CRS_BOOST: Color(0.0, 0.90, 0.50),
	Type.PNP_NOMINATION: Color(0.58, 0.18, 0.92),
	Type.LMIA_SHIELD: Color(0.08, 0.58, 1.0),
}

var powerup_type: Type = Type.NOC_COIN
var scroll_speed: float = 400.0

var _bob_timer: float = 0.0
var _base_y: float = 0.0

signal collected(type: int)


func setup(type: Type, speed: float) -> void:
	powerup_type = type
	scroll_speed = speed
	_build_visuals()
	_setup_collision()
	body_entered.connect(_on_body_entered)


func _ready() -> void:
	_base_y = position.y


func _build_visuals() -> void:
	var rect := ColorRect.new()
	rect.color = COLOR_MAP[powerup_type]
	rect.size = Vector2(52.0, 52.0)
	rect.position = Vector2(-26.0, -26.0)
	add_child(rect)

	var lbl := Label.new()
	lbl.text = EMOJI_MAP[powerup_type]
	lbl.add_theme_font_size_override("font_size", 30)
	lbl.position = Vector2(-15.0, -22.0)
	add_child(lbl)


func _setup_collision() -> void:
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 28.0
	col.shape = shape
	add_child(col)


func _physics_process(delta: float) -> void:
	position.x -= scroll_speed * delta
	_bob_timer += delta
	position.y = _base_y + sin(_bob_timer * 3.0) * 8.0
	if position.x < -200.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		collected.emit(int(powerup_type))
		queue_free()
