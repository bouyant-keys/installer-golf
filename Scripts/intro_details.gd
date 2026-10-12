extends Node

signal start_golf

@export var stage : Stage
@export var ball : Ball
@export var goal : GoalArea
@export var popup_window: WindowPanel
@export var start_button: UIButton

func _ready() -> void:
	start_golf.connect(stage._on_golf_start)

func _on_start_button_pressed() -> void:
	start_golf.emit()
	start_button.set_disabled_state(true)
	popup_window.enter()
	
	await popup_window.entered
	ball.enter()
	goal.enter()
	popup_window.select()
