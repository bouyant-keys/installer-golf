class_name WindowPanel extends Control

const BOUNDS_NUDGE_MIN := Vector2(4.0, 24.0)
const BOUNDS_NUDGE_MAX := Vector2(64.0, 24.0)
const TITLE_FORMAT := "Installer"
const TRANSLUCENT_VALUE : float = 0.2
const ENTER_TIME := 0.4
const EXIT_TIME := 0.4

var is_selected := false
var start_position : Vector2
var move_start : Vector2
var drag_start : Vector2
var is_draggable := true
var grabbable := false
var dragging := false
var minimized := false

@export var enter_on_start := true
@export var is_locked := false
@export var is_minimized := false
@export var override_movable_area := false
@export var title_text : String
@export var grab_bar_color : Color = Color(0.0, 0.0, 0.502)
@export var closable := false
## Control nodes that are activated / deactivated on tab change, index = tab index

@onready var panel_parent: Control = %PanelParent # Node that is tweened on enter / exit
@onready var grab_bar: PanelContainer = %GrabBar
@onready var window_title: Label = %WindowTitle
@onready var lock_icon: TextureRect = %LockIcon
@onready var move_panel: PanelContainer = %MovePanel
@onready var move_area: MoveArea = %MoveArea
@onready var move_collider: CollisionShape2D = %MoveCollider
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var header_collider: CollisionShape2D = %HeaderCollider

@onready var enter_sfx: AudioStreamPlayer = $EnterSFX
@onready var exit_sfx: AudioStreamPlayer = $ExitSFX

signal entered
signal exited
signal ball_entered
signal ball_exited
signal window_selected(window:WindowPanel)
signal window_grabbed(window:WindowPanel)
signal window_released(window:WindowPanel)
signal window_closed(window:WindowPanel)
signal reordered(z_index:int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = global_position
	grab_bar.self_modulate = grab_bar_color
	
	if title_text.is_empty():
		window_title.text = name
	else:
		window_title.text = title_text
	
	move_area.monitorable = !override_movable_area
	move_area.monitoring = !override_movable_area
	
	var header_shape := RectangleShape2D.new()
	header_shape.size = grab_bar.get_rect().size
	header_collider.shape = header_shape
	header_collider.position = grab_bar.get_rect().get_center()
	
	set_locked(is_locked)
	set_children_visibility(false)

func _gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		print(name + ": just pressed")
		grab()
	elif Input.is_action_pressed("LeftClick") and dragging:
		global_position = move_start + (get_global_mouse_position() - drag_start)
	elif Input.is_action_just_released("LeftClick"):
		print(name + ": just released")
		release()

func enter() ->void:
	panel_parent.show()
	panel_parent.scale = Vector2.ZERO
	panel_parent.pivot_offset_ratio = Vector2(0.5, 0.5)
	enter_sfx.play()
	
	var enter_tween := get_tree().create_tween()
	enter_tween.tween_property(panel_parent, "scale", Vector2.ONE, ENTER_TIME)
	
	await enter_tween.finished
	entered.emit()
	set_children_visibility(true)

func exit() ->void:
	set_children_visibility(false)
	panel_parent.show()
	panel_parent.scale = Vector2.ONE
	panel_parent.pivot_offset_ratio = Vector2(0.5, 0.5)
	exit_sfx.play()
	
	var exit_tween := get_tree().create_tween()
	exit_tween.tween_property(panel_parent, "scale", Vector2.ZERO, EXIT_TIME)
	
	await exit_tween.finished
	exited.emit()
	hide()


func select() ->void:
	window_selected.emit(self)

func grab() ->void:
	select()
	
	if !grabbable:
		return
	
	if is_locked:
		anim.play("locked")
		return
	
	dragging = true
	drag_start = get_global_mouse_position()
	move_start = global_position
	window_grabbed.emit(self)

func release() ->void:
	dragging = false
	
	var enclose_rect := get_viewport_rect()
	global_position = global_position.clamp(enclose_rect.position + BOUNDS_NUDGE_MIN, enclose_rect.end - BOUNDS_NUDGE_MAX)
	
	#if global_position != move_start:
		#window_released.emit(self) # Change to window_moved ??
	window_released.emit(self)


func set_children_visibility(active:bool) ->void:
	for child : Node in get_children():
		if child is StaticObstacle:
			continue
		elif child is Node2D:
			child.visible = active
		elif child is Control:
			child.visible = active

func set_z_order(z:int) ->void:
	z_index = z
	reordered.emit(z)

func set_locked(locked:bool) ->void:
	is_locked = locked
	lock_icon.visible = locked
	grab_bar.mouse_default_cursor_shape = Control.CURSOR_ARROW if is_locked else Control.CURSOR_DRAG
	set_process_input(!locked)

func toggle_minimized() ->void:
	minimized = !minimized
	move_panel.visible = !minimized
	move_area.monitorable = !minimized
	move_area.monitoring = !minimized


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

func get_move_area_position() ->Vector2:
	return move_area.get_collider_position()


func _on_grab_bar_entered() ->void:
	grabbable = true

func _on_grab_bar_exited() ->void:
	grabbable = false


func _on_move_area_entered(body: Node2D) -> void:
	if body is Ball:
		is_draggable = false
		if body.z_index < z_index:
			set_translucent(true)
		else:
			ball_entered.emit()
		print("Ball entered ", name, ", WindowZ: ", z_index, ", BallZ: ", body.z_index)

func _on_move_area_exited(body: Node2D) -> void:
	if body is Ball:
		is_draggable = true
		set_translucent(false)
		ball_exited.emit()
		print("Ball exited ", name, ", is_draggable: ", is_draggable)


func _on_visibility_changed() ->void:
	move_area.monitorable = visible
	move_area.monitoring = visible

func set_translucent(active:bool) ->void:
	print("Setting Translucent!!")
	modulate.a = TRANSLUCENT_VALUE if active else 1.0

func _reset() ->void:
	global_position = start_position
