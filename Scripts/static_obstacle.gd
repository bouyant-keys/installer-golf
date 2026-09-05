class_name StaticObstacle extends AnimatableBody2D

var start_position : Vector2
var local_pos : Vector2

@export var parent_window : WindowPanel
@export var move_with_parent := true
@export var tab_id := -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = global_position
	
	if parent_window == null:
		var parent := get_parent()
		if parent is WindowPanel:
			parent_window = parent
		else:
			printerr("ERROR: parent_window on StaticObstacle " + name + " is null and is not a child of a WindowPanel node!")
	
	parent_window.ball_entered.connect(ball_entered_window)
	parent_window.ball_exited.connect(ball_exited_window)
	parent_window.resized.connect(_on_window_resized)
	
	if parent_window is TabWindow:
		parent_window.window_tab_changed.connect(on_window_tab_changed)
	
	set_physics_process(move_with_parent)
	local_pos = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	#global_position = (follow.global_position + follow_offset) + collider.shape.get_rect().size / 2.0
	global_position = parent_window.global_position + local_pos


func set_collision(active:bool) ->void:
	for child : Node2D in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", !active)
		elif child is CollisionPolygon2D:
			child.set_deferred("disabled", !active)


func ball_entered_window() ->void:
	if tab_id > -1:
		set_collision(tab_id == parent_window.selected_tab)
	else:
		set_collision(true)

func ball_exited_window() ->void:
	set_collision(false)

func on_window_tab_changed(index:int) ->void:
	set_collision(index == tab_id)

# Don't move goal area if parent window's position changes when resized.
func _on_window_resized() ->void:
	print("...resize!!")
	global_position = start_position
