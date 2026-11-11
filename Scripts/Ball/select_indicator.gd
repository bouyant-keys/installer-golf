extends Sprite2D

const MOVE_SPEED := 0.3
const MOVE_RANGE := 6.0

var move_tween : Tween
var start_pos : Vector2

@export var valid_indicator : Texture2D
@export var invalid_indicator : Texture2D
@export var reset_indicator : Texture2D

@onready var ball: Ball = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = position
	ball.ball_entered.connect(_on_ball_entered)
	ball.ball_launched.connect(_on_ball_launched)
	ball.ball_stopped.connect(_on_ball_stopped)
	ball.ball_reset.connect(_on_ball_reset)
	hide()

func _process(delta: float) -> void:
	# Move indicator up and down based on MOVE_SPEED & RANGE
	var y_pos := (sin(Time.get_ticks_msec() * delta * MOVE_SPEED) * MOVE_RANGE)
	position = Vector2(start_pos.x, start_pos.y + y_pos)


func show_indicator() ->void:
	set_process(true)
	show()

func hide_indicator() ->void:
	set_process(false)
	hide()


func _on_valid_spot() ->void: 
	texture = valid_indicator
	self_modulate = Color.WHITE
func _on_invalid_spot() ->void: 
	texture = invalid_indicator
	self_modulate = Color.RED

func _on_ball_entered() ->void:
	_on_valid_spot()
	show_indicator()
func _on_ball_stopped(reset:bool) ->void:
	texture = reset_indicator if reset else valid_indicator
	self_modulate = Color.WHITE
	show_indicator()
func _on_ball_launched() ->void: hide_indicator()
func _on_ball_reset() ->void: hide_indicator()
