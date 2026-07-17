class_name GoalArea extends Area2D

const DOWNLOAD_TIME := 1.0
const DEF_BUTTON_TEXT : String = "Next"
const FINAL_BUTTON_TEXT : String = "Install"

@export var is_final_level := false

@onready var download_bar: ProgressBar = %DownloadBar
@onready var goal_button: Button = $GoalButton

signal goal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	download_bar.value = 0.0
	goal_button.button_pressed = false
	
	goal_button.text = FINAL_BUTTON_TEXT if is_final_level else DEF_BUTTON_TEXT


func _on_body_entered(body: Node2D) -> void:
	if body is not Ball:
		return
	
	print("Winnar!")
	goal_button.button_pressed = true
	
	var download_tween := get_tree().create_tween()
	download_tween.tween_property(download_bar, "value", 100.0, DOWNLOAD_TIME)
	
	await download_tween.finished
	goal.emit()

func _on_body_exited(body: Node2D) -> void:
	if body is not Ball:
		return
	
	goal_button.button_pressed = false
