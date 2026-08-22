extends Node

const INSTALL_TIME := 2.5

@onready var install_window: UIWindow = %InstallWindow
@onready var progress_bar: TextureProgressBar = %ProgressBar
@onready var complete_text: CustomRichText = %CompleteText
@onready var installing_text: CustomRichText = %InstallingText
@onready var software: Control = %Software

signal exit_windows
signal launch_software

func _ready() -> void:
	software.hide()
	install_window.hide()
	installing_text.hide()
	complete_text.hide()

func on_confirm() ->void:
	await install_window.enter()
	installing_text.show()
	complete_text.hide()
	progress_bar.value = progress_bar.min_value
	
	var progress_tween := get_tree().create_tween()
	progress_tween.tween_property(progress_bar, "value", progress_bar.max_value, INSTALL_TIME)
	
	await progress_tween.finished
	installing_text.hide()
	complete_text.show()
	
	await get_tree().create_timer(0.4).timeout
	exit_windows.emit()
	
	await get_tree().create_timer(0.4).timeout
	launch_software.emit()
