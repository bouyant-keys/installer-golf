extends Stage

@onready var software_window: WindowPanel = %SoftwareWindow

func _on_replay_button_pressed() -> void:
	# Load first level, last + 1 = 0.
	stage_goal.emit()

func _on_quit_button_pressed() -> void:
	ball.fall()
	await software_window.exit()
	get_tree().quit()
