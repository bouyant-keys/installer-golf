extends Area2D

@onready var exit_button: Button = $ExitButton
@onready var exit_sfx: AudioStreamPlayer = $ExitSFX
@onready var mouse_press_sfx: AudioStreamPlayer = $MousePressSFX

func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		exit()

func _on_exit_button_pressed() -> void:
	exit()


func exit() ->void:
	exit_sfx.play()
	
	await exit_sfx.finished
	get_tree().quit()
