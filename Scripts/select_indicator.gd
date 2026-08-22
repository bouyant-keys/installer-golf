extends Sprite2D

const UP_POS := Vector2(0.0, -24.0)
const DOWN_POS := Vector2(0.0, -14.0)
const MOVE_TIME := 0.5

var move_tween : Tween

@onready var ball: Ball = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball.ball_entered.connect(show_indicator)
	ball.ball_launched.connect(hide_indicator)
	hide()

func show_indicator() ->void:
	show()
	move_up()

func hide_indicator() ->void:
	if move_tween:
		move_tween.kill()
	hide()

func move_up() ->void:
	move_tween = get_tree().create_tween().set_loops()
	move_tween.tween_property(self, "position", UP_POS, MOVE_TIME).set_delay(0.1)
	move_tween.tween_property(self, "position", DOWN_POS, MOVE_TIME).set_delay(0.1)
