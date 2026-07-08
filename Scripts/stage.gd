class_name Stage extends Node

const GOAL_WAIT_TIME := 1.0

signal reset
signal next_stage

@onready var ball: Ball = %Ball
@onready var goal_area: GoalArea = %GoalArea
@onready var window_manager: WindowManager = %WindowManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset.connect(ball._on_stage_reset)
	reset.connect(window_manager._on_stage_reset)
	goal_area.goal.connect(_on_goal)

func reset_stage() ->void:
	print("Resetting Stage.")
	reset.emit()

func _on_goal() ->void:
	await get_tree().create_timer(GOAL_WAIT_TIME).timeout
	next_stage.emit()
