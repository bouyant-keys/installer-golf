extends Node2D

@export var ball : Ball

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() ->void:
	if !ball.current_window:
		return
	var move_pos := ball.get_current_window().get_movable_area().position
	draw_circle(move_pos + ball.local_position, 8.0, Color.GREEN)
	draw_rect(ball.current_window.get_movable_area(), Color.REBECCA_PURPLE, false, 4.0)
