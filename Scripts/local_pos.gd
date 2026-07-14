extends Node2D

@export var ball : Ball

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() ->void:
	if !ball.current_window:
		return
	var move_rect := ball.get_current_window().get_movable_area()
	draw_circle(move_rect.position + ball.local_position, 8.0, Color.GREEN)
	draw_circle(move_rect.position + ball.local_position + (ball.velocity.normalized() * ball.CHECK_DIST), 4.0, Color.BLACK)
	draw_rect(move_rect, Color.REBECCA_PURPLE, false, 4.0)
