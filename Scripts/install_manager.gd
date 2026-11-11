extends Node

const INSTALL_TIME := 2.5
const HOLD_TIME := 2.0
const BOUNCE_HEIGHT := Vector2(0.0, -8.0)

@export var install_animation: AnimationPlayer
@export var install_sfx: AudioStreamPlayer
@export var complete_color : Color
@export var confirm_button: UIButton

@onready var window_manager: WindowManager = %WindowManager
@onready var goal_area: GoalArea = %GoalArea
@onready var confirmation_window: WindowPanel = %ConfirmationWindow
@onready var install_window: WindowPanel = %InstallWindow
@onready var progress_bar: TextureProgressBar = %ProgressBar
@onready var complete_text: CustomRichText = %CompleteText
@onready var installing_text: CustomRichText = %InstallingText

signal launch_software
signal golf_end

func _ready() -> void:
	installing_text.hide()
	complete_text.hide()
	goal_area.goal.connect(_on_goal)

func _on_goal() ->void:
	await get_tree().create_timer(Stage.GOAL_WAIT_TIME).timeout
	window_manager._exit_windows()
	golf_end.emit()

func _on_progress_complete() ->void:
	confirmation_window.enter()

func on_confirm() ->void:
	confirm_button.set_disabled_state(true)
	
	await install_window.enter()
	installing_text.show()
	complete_text.hide()
	install_animation.play("Install")
	
	await install_animation.animation_finished
	progress_bar.tint_progress = complete_color
	install_sfx.play()
	installing_text.hide()
	complete_text.show()
	on_installed()
	
	await get_tree().create_timer(HOLD_TIME).timeout
	await close_windows()
	await get_tree().create_timer(Stage.WINDOWS_EXIT_WAIT).timeout
	launch_software.emit()

func on_installed()->void:
	var start_pos := install_window.global_position
	var bounce_pos := install_window.global_position + BOUNCE_HEIGHT
	
	install_window.global_position = bounce_pos
	
	var bounce_tween := get_tree().create_tween()
	bounce_tween.tween_property(install_window, "global_position", start_pos, 0.8)
	bounce_tween.set_ease(Tween.EASE_IN)
	bounce_tween.set_trans(Tween.TRANS_ELASTIC)

func close_windows() ->void:
	window_manager._exit_windows()
	await get_tree().create_timer(WindowManager.WIN_ENTER_TIME).timeout
	confirmation_window.exit()
	await get_tree().create_timer(WindowManager.WIN_ENTER_TIME).timeout
	install_window.exit()
	await get_tree().create_timer(WindowManager.WIN_ENTER_TIME).timeout
