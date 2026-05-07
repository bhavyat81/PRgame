extends Node2D

# ParallaxBackground — stub for future multi-layer scrolling sky/ground.
# Currently the Game scene builds the background directly.
# Future: add cloud layers, city skyline, etc.

# Scroll speeds for each depth layer (pixels/sec)
@export var layer_speeds: Array[float] = [40.0, 100.0, 220.0]


func _ready() -> void:
	pass  # Background layers are built directly in Game.gd for the MVP


func _process(_delta: float) -> void:
	pass  # Future: scroll individual layers at their respective speeds
