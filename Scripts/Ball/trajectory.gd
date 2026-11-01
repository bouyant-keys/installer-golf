extends Line2D

const MIN_TRAJECTORY_LENGTH := 16.0 # Line length in pixels by default
const MAX_TRAJECTORY_LENGTH := 360.0
const STRENGTH_RATIO := 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func _on_trajectory_changed(trajectory:Vector2, strength:float, strength_range:Vector2) ->void:
	clear_points()
	add_point(Vector2.ZERO)
	
	var adj_strength := MAX_TRAJECTORY_LENGTH * ((strength-strength_range.x) / strength_range.y)
	adj_strength = clampf(adj_strength, MIN_TRAJECTORY_LENGTH, MAX_TRAJECTORY_LENGTH)
	add_point(trajectory.normalized() * adj_strength)

func _enable_trajectory(enable:bool) ->void:
	visible = enable
