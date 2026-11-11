class_name Software extends Stage

const HUE_CHANGE := 0.1

var current_goal_pos := 0

@export var bg : GradientTexture2D
@export var goal_positions: Array[Node2D]

@onready var software_window: WindowPanel = %SoftwareWindow
@onready var bg_color: TextureRect = %BGColor

signal software_entered
signal software_exited

func _process(delta: float) -> void:
	var bg_gradient := bg.gradient
	var new_bg_colors : PackedColorArray
	for i : int in bg_gradient.colors.size():
		var color := bg_gradient.colors[i]
		color.h += HUE_CHANGE * delta
		new_bg_colors.append(color)
	bg.gradient.colors = new_bg_colors
	bg_color.texture = bg

func _on_goal() ->void:
	# move goal somewhere else and respawn
	await get_tree().create_timer(GOAL_WAIT_TIME).timeout
	current_goal_pos = posmod(current_goal_pos + 1, goal_positions.size())
	goal_area.global_position = goal_positions[current_goal_pos].global_position
	goal_area.enter()


func _on_software_entered() ->void:
	software_entered.emit()

func _on_software_exited() ->void:
	print("software exited")
	software_exited.emit()

func unload_software() ->void:
	ball.exit()
	goal_area.anim.play("goal")
	await get_tree().create_timer(Stage.GOAL_WAIT_TIME).timeout
	exit_windows.emit()
	await window_manager.windows_exited
	await get_tree().create_timer(WINDOWS_EXIT_WAIT).timeout

func _on_replay_button_pressed() -> void:
	# Load first level, last + 1 = 0.
	await unload_software()
	next_stage()

func _on_quit_button_pressed() -> void:
	await unload_software()
	get_tree().quit()
