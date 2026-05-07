extends Node

# Main entry point — routes immediately to the Start Screen.
# This node exists so Godot has a stable main_scene to boot from.

func _ready() -> void:
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")
