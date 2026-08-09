extends Line2D

var bar_complete := false
var fading := false

@export var stage : Stage
@export var ball : Ball
@export var goal : Area2D

@onready var fade_timer: Timer = $FadeTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stage.reset.connect(_on_stage_reset)
	ball.ball_launched.connect(_on_ball_launched)
	ball.ball_fell.connect(_on_ball_fell)
	set_process(false)
	#ball.direction_changed.connect(_on_ball_direction_changed)

func _process(_delta: float) -> void:
	z_index = ball.z_index
	add_point(ball.global_position)
	
	if fading:
		remove_point(0)

func on_fade_timer_timeout() ->void:
	fading = true

func _on_ball_launched() ->void:
	set_process(true)
	fade_timer.start()

#func _on_ball_direction_changed(pos:Vector2) ->void:
	#if bar_complete:
		#return
	#add_point(pos)
#
#func _on_goal() ->void:
	#print("Drawing loading bar!!!")
	#add_point(goal.global_position)
	#bar_complete = true
	##show()

func _on_stage_reset() ->void:
	clear_points()
	bar_complete = false
	#hide()

func _on_ball_fell() ->void:
	clear_points()
	clear_points()
	set_process(false)


func _on_goal_area_goal() -> void:
	pass # Replace with function body.
