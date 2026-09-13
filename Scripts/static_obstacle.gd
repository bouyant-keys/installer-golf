class_name StaticObstacle extends AnimatableBody2D

const CLIPMASK_OFFSET := Vector2(4.0, 24.0)

var relative_global : Vector2
var relative_local : Vector2
var resizing := false
var grabbed := true
var header_collider : CollisionShape2D

@export var testing := false
@export var is_header := false
@export var is_disabled := false
@export var parent_window : WindowPanel
@export var tab_id := -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	relative_global = global_position
	relative_local = global_position - parent_window.global_position
	
	if parent_window == null:
		var parent := get_parent()
		if parent is WindowPanel:
			parent_window = parent
		else:
			printerr("ERROR: parent_window on StaticObstacle " + name + " is null and is not a child of a WindowPanel node!")
	
	if !parent_window.resized.is_connected(_on_window_resized):
		parent_window.ball_entered.connect(ball_entered_window)
		parent_window.ball_exited.connect(ball_exited_window)
		parent_window.window_grabbed.connect(_on_window_grabbed)
		parent_window.window_released.connect(_on_window_released)
		parent_window.resized.connect(_on_window_resized)
		
		if parent_window is TabWindow:
			parent_window.window_tab_changed.connect(_on_window_tab_changed)
		elif parent_window is ResizableWindow:
			parent_window.resize_start.connect(_on_resize_start)
			parent_window.resize_end.connect(_on_resize_end)
	
	if is_header:
		header_collider = get_child(0) as CollisionShape2D
	
	set_collision(!is_disabled)
	set_process(false)

func _process(_delta: float) -> void:
	print(parent_window.global_position - global_position)

func set_collision(active:bool) ->void:
	for child : Node2D in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", !active)
		elif child is CollisionPolygon2D:
			child.set_deferred("disabled", !active)


func ball_entered_window() ->void:
	#print("StaticObstacle -- Ball entered window: ", name)
	if tab_id > -1:
		set_collision(tab_id == parent_window.selected_tab)
	else:
		set_collision(true)

func ball_exited_window() ->void:
	#print("StaticObstacle -- Ball exited window: ", name)
	set_collision(false)


func _on_window_tab_changed(index:int) ->void:
	set_collision(index == tab_id)

func _on_window_grabbed(_window:WindowPanel) ->void:
	grabbed = true
	set_process(testing and grabbed)

func _on_window_released(_window:WindowPanel) ->void:
	print("released")
	grabbed = false
	# For some reason static obstacles move around when their window is moved?
	# Resetting the local position fixes it, but don't know what caused it.
	#if parent_window is not ResizableWindow:
	position = relative_local
	relative_global = global_position
	set_process(false)

func _on_window_resized() ->void:
	if !is_header:
		# Don't move node if parent window's position changes when resized.
		global_position = relative_global


func _on_resize_start() ->void:
	print("resize_start")
	#relative_global = parent_window.global_position
	#set_physics_process(false)
func _on_resize_end() ->void:
	print("resize_end")
	relative_local = relative_global - CLIPMASK_OFFSET - parent_window.global_position
	position = relative_local
