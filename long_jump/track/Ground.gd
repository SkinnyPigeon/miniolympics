extends Area2D

signal landed

func _on_area_entered(_area):
	emit_signal("landed")
