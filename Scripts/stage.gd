class_name Stage extends Node

signal reset
signal next_stage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func reset_stage() ->void:
	print("Resetting Stage.")
	reset.emit()

func _on_goal() ->void:
	next_stage.emit()
