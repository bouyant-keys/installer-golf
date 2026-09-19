extends Node

@onready var popup_window: WindowPanel = $"../WindowManager/PopupWindow"
@onready var retry_button: UIButton = $"../WindowManager/TutorialWindow/NavPanel/HBoxContainer/RetryButton"
@onready var back_button: UIButton = $"../WindowManager/TutorialWindow/NavPanel/HBoxContainer/BackButton"
@onready var next_button: UIButton = $"../WindowManager/TutorialWindow/NavPanel/HBoxContainer/NextButton"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	retry_button.set_button_text("Start")
	back_button.hide()

func _on_retry_button_pressed() -> void:
	retry_button.set_button_text("Retry")
	popup_window.enter()
	
	await popup_window.entered
	popup_window.select()
