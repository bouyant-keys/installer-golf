extends Area2D

signal goal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func on_area_entered(_area:Area2D) ->void:
	print("Winnar!")
	goal.emit()
