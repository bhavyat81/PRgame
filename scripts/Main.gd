extends Node

# Main entry point — routes immediately to the Start Screen.
# This node exists so Godot has a stable main_scene to boot from.
#
# NOTE: change_scene_to_file() must be deferred — calling it during _ready()
# while the parent (SceneTree root) is still adding children raises:
#   "Parent node is busy adding/removing children, remove_child() can't be called"

func _ready() -> void:
	call_deferred("_go_to_start")


func _go_to_start() -> void:
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")
