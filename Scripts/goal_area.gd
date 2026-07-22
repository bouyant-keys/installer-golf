class_name GoalArea extends Area2D

const DOWNLOAD_TIME := 1.0
const DEF_BUTTON_TEXT : String = "Next"
const FINAL_BUTTON_TEXT : String = "Install"

@export var is_final_level := false

@onready var download_bar: ProgressBar = %DownloadBar
@onready var goal_button: Button = $GoalButton
@onready var goal_pressed_sfx: AudioStreamPlayer = $GoalPressedSFX
@onready var mouse_press_sfx: AudioStreamPlayer = $MousePressSFX

signal goal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	download_bar.value = 0.0
	goal_button.button_pressed = false
	
	goal_button.text = FINAL_BUTTON_TEXT if is_final_level else DEF_BUTTON_TEXT


func _on_body_entered(body: Node2D) -> void:
	if body is not Ball:
		return
	
	goal_pressed_sfx.play()
	goal_button.button_pressed = true
	
	var download_tween := get_tree().create_tween()
	download_tween.tween_property(download_bar, "value", 100.0, DOWNLOAD_TIME)
	
	await download_tween.finished
	goal.emit()

func _on_body_exited(body: Node2D) -> void:
	if body is not Ball:
		return
	
	goal_button.button_pressed = false


func _on_goal_button_pressed() -> void:
	mouse_press_sfx.play()
	
	goal_button.self_modulate = Color.RED
	var color_tween := get_tree().create_tween()
	color_tween.tween_property(goal_button, "self_modulate", Color.WHITE, 1.0)
