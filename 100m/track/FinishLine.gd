extends Area2D

signal finished(ids)


func _on_area_entered(_area):
	var finished_runners = get_overlapping_areas()
	var ids = []
	for runner_area in finished_runners:
		var runner = runner_area.get_parent().get_parent()
		ids.append(runner.get_instance_id())
	emit_signal("finished", ids)
