class_name StageManager extends Node

var stage_index := 0
var current_stage : Stage
var stage_completion : Array[bool]

@export_range(0, 12) var start_stage : int = 0
@export var stages : Array[PackedScene]
@export var back_button : UIButton
@export var next_button : UIButton

signal software_start
signal software_end
signal game_start
signal game_end
signal stage_changed(index:int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	next_button.pressed.connect(_on_next_pressed)
	
	for i : int in stages.size():
		stage_completion.append(false)
	
	for child in get_children():
		if child is Stage:
			current_stage = child as Stage
	
	await get_tree().process_frame
	load_stage(start_stage)
	if start_stage != 0:
		game_start.emit()

func _on_golf_start() ->void: game_start.emit()
func _on_golf_end() ->void: game_end.emit()

func _on_software_enter() ->void: software_start.emit()
func _on_software_exit() ->void: software_end.emit()


func load_stage(index:int) ->void:
	print("Moving to stage: ", index+2)
	if current_stage:
		current_stage.queue_free()
	
	stage_index = clampi(index, 0, stages.size()-1)
	stage_changed.emit(stage_index)
	
	current_stage = stages[stage_index].instantiate() as Stage
	current_stage.stage_goal.connect(_on_stage_goal)
	current_stage.golf_start.connect(_on_golf_start)
	current_stage.golf_end.connect(_on_golf_end)
	if current_stage is Software:
		current_stage.software_entered.connect(_on_software_enter)
		current_stage.software_exited.connect(_on_software_exit)
	
	add_child(current_stage)
	
	# Update back / next buttons
	if stage_index == 0:
		next_button.set_disabled_state(stage_completion[stage_index] == false)
		back_button.set_disabled_state(true) # Cannot go back from initial stage
	elif stage_index == stages.size()-1:
		next_button.set_disabled_state(true) # Cannot go to next at final stage
		back_button.set_disabled_state(stage_completion[stage_index-1] == false)
	else:
		next_button.set_disabled_state(stage_completion[stage_index] == false)
		back_button.set_disabled_state(stage_completion[stage_index-1] == false)

func load_next_stage() ->void: load_stage(posmod(stage_index+1, stages.size()))
func load_previous_stage() ->void: load_stage(posmod(stage_index-1, stages.size()))


func _on_stage_goal() ->void:
	stage_completion[stage_index] = true
	load_next_stage()

func _on_back_pressed() -> void: load_previous_stage()
func _on_next_pressed() -> void: load_next_stage()


func _on_progress_full() ->void:
	current_stage._on_progress_full()
