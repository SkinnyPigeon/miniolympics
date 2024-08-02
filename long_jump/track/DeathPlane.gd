extends Area2D

signal death

func _on_area_entered(_area):
	var areas = get_overlapping_areas()
	var ids = []
	for area in areas:
		var object = area.get_parent().get_parent()
		ids.append(object.get_instance_id())
	emit_signal("death", ids)
