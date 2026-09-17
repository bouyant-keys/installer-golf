class_name StaticObstacle extends AnimatableBody2D

const CLIPMASK_OFFSET := Vector2(4.0, 24.0)

var relative_global : Vector2
var relative_local := Vector2.ZERO
#var parent_offset : Vector2
var resizing := false
var grabbed := false
var header_collider : CollisionShape2D

@export var testing := false
@export var is_header := false
@export var is_disabled := false
@export var parent_window : WindowPanel
@export var tab_id := -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	relative_global = global_position
	
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
	
	if is_header:
		header_collider = get_child(0) as CollisionShape2D
	
	set_collision(!is_disabled)
	#set_process(false)

func _physics_process(_delta: float) -> void:
	if grabbed:
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
	print(" -- collision disabled ball exited.")
	set_collision(false)
#endregion

#region Window Signals
func _on_window_tab_changed(index:int) ->void:
	set_collision(index == tab_id)

func _on_window_grabbed(_window:WindowPanel) ->void:
	#print(name + ": parent window grabbed.")
	relative_local = global_position - parent_window.global_position
	grabbed = true

func _on_window_released(_window:WindowPanel) ->void:
	#print(name + ": parent window released.")
	relative_global = global_position
	grabbed = false

func _on_window_resize_start(_window:ResizableWindow) ->void:
	#print(name + ": resize_start")
	pass

func _on_window_resized(_window:ResizableWindow) ->void:
	if is_header:
		# We want the header to move with the parent -- just stuck to the top left corner
		position = Vector2.ZERO
		return
	# Don't move node if parent window's position changes when resized.
	global_position = relative_global

func _on_window_resize_end(_window:ResizableWindow) ->void:
	#print(name + ": resize_end.")
	pass
#endregion
