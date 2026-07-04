extends Line2D

var bar_complete := false

@export var stage : Stage
@export var goal : Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stage.reset.connect(_on_stage_reset)
	#hide()
	pass

func _on_ball_bounce(pos:Vector2) ->void:
	if bar_complete:
		return
	add_point(pos)

func _on_goal() ->void:
	print("Drawing loading bar!!!")
	add_point(goal.global_position)
	bar_complete = true
	#show()

func _on_stage_reset() ->void:
	clear_points()
	bar_complete = false
	#hide()
