class_name Stage extends Node

const GOAL_WAIT_TIME := 2.0
const WINDOWS_ENTER_WAIT := 0.5
const BALL_ENTER_WAIT := 0.5
const GOAL_ENTER_WAIT := 0.5

signal reset
signal next_stage
signal enter_windows
signal exit_windows
signal enter_ball
signal enter_goal

@export var back_button : UIButton
@export var retry_button : UIButton
@export var next_button : UIButton
@export var next_stage_on_goal := true

@onready var ball: Ball = %Ball
@onready var goal_area: GoalArea = %GoalArea
@onready var window_manager: WindowManager = %WindowManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	if retry_button:
		retry_button.pressed.connect(reset_stage)
	
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
	
	
	reset.connect(ball._on_stage_reset)
	reset.connect(window_manager._on_stage_reset)
	enter_ball.connect(ball._on_stage_reset)
	enter_goal.connect(goal_area.enter)
	goal_area.goal.connect(_on_goal)
	
	stage_setup.call_deferred()

func stage_setup() ->void:
	enter_windows.emit()
	
	await window_manager.windows_entered
	if ball.enter_on_load:
		enter_ball.emit()
	if !goal_area.is_intro_level:
		enter_goal.emit()

func reset_stage() ->void:
	print("Resetting Stage.")
	reset.emit()

func unload_stage() ->void:
	exit_windows.emit()

func _on_next_pressed() ->void:
	enter_ball.emit()
	enter_goal.emit()

func _on_back_pressed() ->void:
	reset_stage()

func _on_goal() ->void:
	if !next_stage_on_goal:
		return
	
	await get_tree().create_timer(GOAL_WAIT_TIME).timeout
	unload_stage()
	await get_tree().create_timer(WindowPanel.EXIT_TIME + 0.3).timeout
	next_stage.emit()
