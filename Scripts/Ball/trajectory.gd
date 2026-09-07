extends Line2D

const DEF_TRAJECTORY_LENGTH := 24.0 # Line length in pixels by default
const STRENGTH_RATIO := 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func _on_trajectory_changed(trajectory:Vector2, strength:float) ->void:
	clear_points()
	add_point(Vector2.ZERO)
	
	var adj_strength := DEF_TRAJECTORY_LENGTH + (strength * STRENGTH_RATIO)
	add_point(trajectory.normalized() * adj_strength)

func _enable_trajectory(enable:bool) ->void:
	visible = enable
