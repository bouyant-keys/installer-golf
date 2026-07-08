extends Node

var stage_index := 0
var current_stage : Stage

@export var stages : Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_stage = get_child(0) as Stage
	current_stage.next_stage.connect(on_next_stage)

func on_next_stage() ->void:
	# -- Fade to black --
	print("Moving to stage: ", stage_index+2)
	current_stage.queue_free()
	
	stage_index = clampi(stage_index + 1, 0, stages.size()-1)
	
	current_stage = stages[stage_index].instantiate() as Stage
	current_stage.next_stage.connect(on_next_stage)
	add_child(current_stage)
	
	# -- Fade back in --

func _on_reset_pressed() ->void:
	current_stage.reset_stage()
