extends Node

const LEVEL_BASE = preload("res://scenes/level_base/level_base.tscn")
const MAIN = preload("res://scenes/main/main.tscn")


func load_level() -> void:
	get_tree().change_scene_to_packed(LEVEL_BASE)

func load_main() -> void:
	get_tree().change_scene_to_packed(MAIN)
