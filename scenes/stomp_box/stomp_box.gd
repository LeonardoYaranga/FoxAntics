class_name StompBox
extends Area2D

signal stomped

var _hit: bool = false

var is_hit: bool:
	get: return _hit

func trigger() -> void:
	if _hit: return
	_hit = true
	stomped.emit()
	
