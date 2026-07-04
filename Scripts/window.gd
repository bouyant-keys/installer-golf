class_name WindowPanel extends PanelContainer

var start_position : Vector2
var move_start : Vector2
var drag_start : Vector2
var grabbed := false

@export var is_locked := false

@onready var grab_bar: PanelContainer = %GrabBar
@onready var lock_icon: TextureRect = %LockIcon
@onready var move_panel: PanelContainer = %MovePanel
@onready var move_area: MoveArea = %MoveArea
@onready var move_collider: CollisionShape2D = %MoveCollider

signal window_selected(window:WindowPanel)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = global_position
	
	set_locked(is_locked)
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = move_start + (get_global_mouse_position() - drag_start)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("LeftClick") and grabbed:
		window_selected.emit(self)
		if is_locked:
			return
		drag_start = get_global_mouse_position()
		move_start = global_position
		set_process(true)
	elif event.is_action_released("LeftClick"):
		set_process(false)


func get_neighbouring_windows() ->Array[WindowPanel]:
	var neighbours : Array[WindowPanel]
	var areas := move_area.get_overlapping_areas()
	for area in areas:
		var parent := area.get_parent()
		if parent is WindowPanel:
			neighbours.append(parent)
	return neighbours

func get_movable_area() ->Rect2:
	return move_area.get_movable_area()

func set_locked(locked:bool) ->void:
	is_locked = locked
	lock_icon.visible = locked
	grab_bar.mouse_default_cursor_shape = Control.CURSOR_ARROW if is_locked else Control.CURSOR_DRAG
	set_process_input(!locked)


func _on_grab_bar_entered() ->void:
	grabbed = true

func _on_grab_bar_exited() ->void:
	grabbed = false

func _on_move_area_entered(area: Area2D) -> void:
	pass # Replace with function body.

func _on_move_area_exited(area: Area2D) -> void:
	pass # Replace with function body.

func _on_resized() ->void:
	return
	print(name + "resized. Size: ", size)
	move_area.global_position = move_panel.global_position + (move_panel.size / 2.0)
	var collider := RectangleShape2D.new()
	collider.size = move_panel.size
	move_collider.shape = collider

func _reset() ->void:
	global_position = start_position
