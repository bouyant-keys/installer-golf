class_name Stage extends Node

const GOAL_WAIT_TIME := 2.0
const WINDOWS_ENTER_WAIT := 0.5
const WINDOWS_EXIT_WAIT := 0.5
const BALL_ENTER_WAIT := 0.5
const GOAL_ENTER_WAIT := 0.5

signal golf_start
signal golf_end
signal reset
signal stage_goal
signal enter_windows
signal exit_windows
signal enter_ball
signal enter_goal
signal ball_stopped
signal progress_full

@export var next_stage_on_goal := true

@onready var ball: Ball = %Ball
@onready var goal_area: GoalArea = %GoalArea
@onready var window_manager: WindowManager = %WindowManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball.ball_stopped.connect(_on_ball_stopped)
	
	reset.connect(ball._on_stage_reset)
	reset.connect(window_manager._on_stage_reset)
	enter_ball.connect(ball.enter)
	enter_goal.connect(goal_area.enter)
	goal_area.goal.connect(_on_goal)
	
	stage_setup.call_deferred()

func stage_setup() ->void:
	print("===Stage Setup")
	enter_windows.emit()
	
	await window_manager.windows_entered
	print("====Stage, ball enter_on_load: ", ball.enter_on_load)
	if ball.enter_on_load:
		print("Ball enter now !!!")
		enter_ball.emit()
	if !goal_area.enter_on_load:
		enter_goal.emit()

func stage_exit() ->void:
	exit_windows.emit()
	await window_manager.windows_exited
	await get_tree().create_timer(WINDOWS_EXIT_WAIT).timeout
	next_stage()

func next_stage() ->void:
	stage_goal.emit()

func reset_stage() ->void:
	print("Resetting Stage.")
	reset.emit()

## Only called in intro_stage
func _on_golf_start() ->void: golf_start.emit()
## Only called in outro_stage
func _on_golf_end() ->void: golf_end.emit()

# Called when ProgressWindow in main reaches 100%
func _on_progress_full() ->void: progress_full.emit()

func _on_ball_stopped(_reset:bool) ->void: ball_stopped.emit()

func _on_goal() ->void:
	if !next_stage_on_goal:
		return
	
	await get_tree().create_timer(GOAL_WAIT_TIME).timeout
	stage_exit()
