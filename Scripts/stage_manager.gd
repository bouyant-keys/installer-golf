class_name StageManager extends Node

var stage_index := 0
var current_stage : Stage
var stage_completion : Array[bool]

@export var start_stage : int = 0
@export var stages : Array[PackedScene]
@export var back_button : UIButton
@export var retry_button : UIButton
@export var next_button : UIButton

signal game_start
signal game_end
signal ball_stopped
signal stage_changed(index:int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	next_button.pressed.connect(_on_next_pressed)
	
	for i : int in stages.size():
		stage_completion.append(false)
	
	for child in get_children():
		if child is Stage:
			current_stage = child as Stage
	
	await get_tree().process_frame
	game_start.emit()
	load_stage(start_stage)

func on_start_game() ->void:
	game_start.emit()
	load_stage(0)

func load_stage(index:int) ->void:
	print("Moving to stage: ", index+2)
	if current_stage:
		current_stage.queue_free()
	
	stage_index = clampi(index, 0, stages.size()-1)
	stage_changed.emit(stage_index)
	
	current_stage = stages[stage_index].instantiate() as Stage
	current_stage.stage_goal.connect(_on_stage_goal)
	current_stage.ball_stopped.connect(_on_stage_ball_stopped)
	add_child(current_stage)
	
	# Update back / next buttons
	if stage_index == 0:
		next_button.set_disabled_state(stage_completion[stage_index] == false)
		back_button.set_disabled_state(true)
	elif stage_index == stages.size()-1:
		next_button.set_disabled_state(true)
		back_button.set_disabled_state(stage_completion[stage_index-1] == false)
	else:
		next_button.set_disabled_state(stage_completion[stage_index] == false)
		back_button.set_disabled_state(stage_completion[stage_index-1] == false)

func load_next_stage() ->void: load_stage(stage_index+1)
func load_previous_stage() ->void: load_stage(stage_index-1)


func _on_stage_goal() ->void:
	stage_completion[stage_index] = true
	load_next_stage()

func _on_stage_ball_stopped() ->void:
	retry_button.set_button_blink(true)

func _on_back_pressed() -> void:
	load_previous_stage()

func _on_retry_pressed() -> void:
	retry_button.set_button_blink(false)
	current_stage.reset_stage()

func _on_next_pressed() -> void:
	load_next_stage()
