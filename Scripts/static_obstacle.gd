class_name StaticObstacle extends AnimatableBody2D

const CLIPMASK_OFFSET := Vector2(4.0, 24.0)

var relative_global : Vector2
var relative_local := Vector2.ZERO
var resizing := false
var header_collider : CollisionShape2D

@export var is_disabled := false
@export var parent_window : WindowPanel
@export var tab_id := -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	relative_global = global_position
	
	if !parent_window:
		var parent := get_parent()
		if parent is WindowPanel:
			parent_window = parent
	
	parent_window.ball_entered.connect(ball_entered_window)
	parent_window.ball_exited.connect(ball_exited_window)
	parent_window.window_grabbed.connect(_on_window_grabbed)
	parent_window.window_released.connect(_on_window_released)
	
	if parent_window is TabWindow:
		parent_window.window_tab_changed.connect(_on_window_tab_changed)
	elif parent_window is ResizableWindow:
		parent_window.window_resize_start.connect(_on_window_resize_start)
		parent_window.window_resized.connect(_on_window_resized)
		parent_window.window_resize_end.connect(_on_window_resize_end)
	
	set_collision(!is_disabled)
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	global_position = parent_window.global_position + relative_local

func set_collision(active:bool) ->void:
	for child : Node2D in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", !active)
		elif child is CollisionPolygon2D:
			child.set_deferred("disabled", !active)

#region Ball Signals
func ball_entered_window() ->void:
	if tab_id > -1:
		set_collision(tab_id == parent_window.selected_tab)
	else:
		set_collision(true)

func ball_exited_window() ->void:
	set_collision(false)
#endregion

#region Window Signals
func _on_window_tab_changed(index:int) ->void:
	set_collision(index == tab_id)

func _on_window_grabbed(_window:WindowPanel) ->void:
	relative_local = global_position - parent_window.global_position
	set_physics_process(true)

func _on_window_released(_window:WindowPanel) ->void:
	relative_global = global_position
	set_physics_process(false)

func _on_window_resize_start(_window:ResizableWindow) ->void:
	pass

func _on_window_resized(_window:ResizableWindow) ->void:
	# Don't move node if parent window's position changes when resized.
	global_position = relative_global
	print("heave")

func _on_window_resize_end(_window:ResizableWindow) ->void:
	pass
#endregion
