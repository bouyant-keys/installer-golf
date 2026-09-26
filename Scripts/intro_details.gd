extends Node

@export var ball : Ball
@export var goal : GoalArea
@export var popup_window: WindowPanel
@export var start_button: UIButton

func _on_start_button_pressed() -> void:
	start_button.set_disabled_state(true)
	popup_window.enter()
	
	await popup_window.entered
	ball.enter()
	goal.enter()
	popup_window.select()
