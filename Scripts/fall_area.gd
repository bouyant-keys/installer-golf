extends Area2D

var relative_position : Vector2

@export var parent_window : WindowPanel
@export var tab_id := -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	relative_position = global_position
	
	if !parent_window:
		var parent := get_parent()
		if parent is WindowPanel:
			parent_window = parent
	
	parent_window.ball_entered.connect(ball_entered_window)
	parent_window.ball_exited.connect(ball_exited_window)
	parent_window.reordered.connect(_on_window_reordered)
	parent_window.window_grabbed.connect(_on_window_grabbed)
	parent_window.window_released.connect(_on_window_released)
	
	if parent_window is TabWindow:
		parent_window.window_tab_changed.connect(_on_window_tab_changed)
	
	hide()

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
	print(" -- collision disabled ball exited.")
	set_collision(false)

func _on_window_reordered(z:int) ->void:
	z_index = z

func _on_window_tab_changed(index:int) ->void:
	set_collision(index == tab_id)

func _on_window_grabbed(_window:WindowPanel) ->void:
	#print(name + ": parent window grabbed.")
	#relative_local = global_position - parent_window.global_position
	#grabbed = true
	pass

func _on_window_released(_window:WindowPanel) ->void:
	relative_position = global_position
	print(name + " relative pos set: ", relative_position)

# Don't move goal area if parent window's position changes when resized.
func _on_window_resized() ->void:
	global_position = relative_position
