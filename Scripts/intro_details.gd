extends Node

const TEXT_ENTER_TIME := 2.5

signal start_golf

@export var stage : Stage
@export var ball : Ball
@export var goal : GoalArea
@export var popup_window: WindowPanel
@export var start_button: UIButton
@export var tutorial_text: CustomRichText

@onready var text_sfx: AudioStreamPlayer = $TextSFX

func _ready() -> void:
	tutorial_text.hide()
	start_golf.connect(stage._on_golf_start)

func _on_tutorial_window_entered() ->void:
	tutorial_text.visible_ratio = 0.0
	tutorial_text.show()
	text_sfx.play()
	
	var text_tween := get_tree().create_tween()
	text_tween.tween_property(tutorial_text, "visible_ratio", 1.0, TEXT_ENTER_TIME)
	
	await text_tween.finished
	text_sfx.stop()

func _on_start_button_pressed() -> void:
	start_golf.emit()
	start_button.set_disabled_state(true)
	popup_window.enter()
	
	await popup_window.entered
	ball.enter()
	goal.enter()
	popup_window.select()
