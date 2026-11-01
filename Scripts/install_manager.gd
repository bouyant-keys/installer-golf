extends Node

const INSTALL_TIME := 2.5
const HOLD_TIME := 1.0

@onready var window_manager: WindowManager = %WindowManager
@onready var goal_area: GoalArea = %GoalArea
@onready var confirmation_window: WindowPanel = %ConfirmationWindow
@onready var install_window: WindowPanel = %InstallWindow
@onready var progress_bar: TextureProgressBar = %ProgressBar
@onready var complete_text: CustomRichText = %CompleteText
@onready var installing_text: CustomRichText = %InstallingText

signal launch_software

func _ready() -> void:
	installing_text.hide()
	complete_text.hide()
	goal_area.goal.connect(_on_goal)

func _on_goal() ->void:
	confirmation_window.enter()

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
	
	await get_tree().create_timer(HOLD_TIME).timeout
	await close_windows()
	await get_tree().create_timer(Stage.WINDOWS_EXIT_WAIT).timeout
	launch_software.emit()

func close_windows() ->void:
	window_manager._exit_windows()
	await get_tree().create_timer(WindowManager.WIN_ENTER_TIME).timeout
	confirmation_window.exit()
	await get_tree().create_timer(WindowManager.WIN_ENTER_TIME).timeout
	install_window.exit()
	await get_tree().create_timer(WindowManager.WIN_ENTER_TIME).timeout
