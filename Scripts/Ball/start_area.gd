extends Area2D

signal valid_spot
signal invalid_spot

func _on_body_entered(_body: Node2D) -> void:
	invalid_spot.emit()

func _on_body_exited(_body: Node2D) -> void:
	if get_overlapping_areas().size() == 0:
		valid_spot.emit()
