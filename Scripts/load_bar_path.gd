extends Line2D

var bar_complete := false
var fading := false

@export var stage : Stage
@export var ball : Ball

@onready var fade_timer: Timer = $FadeTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stage.reset.connect(_reset)
	ball.ball_launched.connect(_on_ball_launched)
	ball.ball_stopped.connect(_on_ball_stopped)
	ball.ball_fell.connect(_reset)
	set_process(false)

func _process(_delta: float) -> void:
	z_index = ball.z_index
	add_point(ball.global_position)
	
	if fading:
		remove_point(0)

func on_fade_timer_timeout() ->void:
	fading = true

func _on_ball_launched() ->void:
	print("ball launched -- trail")
	set_process(true)
	fade_timer.start()

func _on_ball_stopped(_reset_on_click:bool) ->void:
	_reset()

func _reset() ->void:
	fade_timer.stop()
	fading = false
	clear_points()
	set_process(false)
