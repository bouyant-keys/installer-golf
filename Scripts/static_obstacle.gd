class_name StaticObstacle extends AnimatableBody2D

var local_pos : Vector2

@export var parent_window : WindowPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if parent_window == null:
		var parent := get_parent()
		if parent is WindowPanel:
			parent_window = parent
		else:
			printerr("ERROR: parent_window on StaticObstacle " + name + " is null and is not a child of a WindowPanel node!")
	
	parent_window.ball_entered.connect(ball_entered_window)
	parent_window.ball_exited.connect(ball_exited_window)
	
	local_pos = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	#global_position = (follow.global_position + follow_offset) + collider.shape.get_rect().size / 2.0
	global_position = get_parent().global_position + local_pos

func ball_entered_window() ->void:
	for child : Node2D in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", false)
		elif child is CollisionPolygon2D:
			child.set_deferred("disabled", false)

func ball_exited_window() ->void:
	for child : Node2D in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
		elif child is CollisionPolygon2D:
			child.set_deferred("disabled", true)
