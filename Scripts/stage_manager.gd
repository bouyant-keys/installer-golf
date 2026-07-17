extends Node

var stage_index := 0
var current_stage : Stage

@export var start_stage : int = 0
@export var stages : Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Stage:
			current_stage = child as Stage
	
	load_stage(start_stage)

func on_next_stage() ->void:
	load_stage(stage_index+1)

func load_stage(index:int) ->void:
	# -- Fade to black --
	print("Moving to stage: ", index+2)
	if current_stage:
		current_stage.queue_free()
	
	stage_index = clampi(index, 0, stages.size()-1)
	
	current_stage = stages[stage_index].instantiate() as Stage
	current_stage.next_stage.connect(on_next_stage)
	add_child(current_stage)
	
	# -- Fade back in --

func _on_reset_pressed() ->void:
	current_stage.reset_stage()
