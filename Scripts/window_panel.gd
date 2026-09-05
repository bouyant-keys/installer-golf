class_name WindowPanel extends Control

const TITLE_FORMAT := "Installer"
const TRANSLUCENT_VALUE : float = 0.2
const ENTER_TIME := 0.4
const EXIT_TIME := 0.4

var is_selected := false
var start_position : Vector2
var move_start : Vector2
var drag_start : Vector2
var is_draggable := true
var grabbed := false
var minimized := false

@export var enter_on_start := true
@export var is_locked := false
@export var is_minimized := false
@export var override_movable_area := false
@export var title_text : String
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
signal reordered(z_index:int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = global_position
	
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
	print(header_collider.position, header_collider.shape.size)
	
	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()
	set_locked(is_locked)
	set_process(false)
	
	set_children_visibility(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = move_start + (get_global_mouse_position() - drag_start)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("LeftClick"):
		select()
		
		if !grabbed:
			return
		
		if is_locked:
			##TODO Visual cue that window is locked in place...
			anim.play("locked")
			return
		drag_start = get_global_mouse_position()
		move_start = global_position
		window_grabbed.emit(self)
		set_process(true)
	elif event.is_action_released("LeftClick"):
		window_released.emit(self)
		set_process(false)


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
	print(name, " Entered - visible:", visible)

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
	grabbed = true

func _on_grab_bar_exited() ->void:
	grabbed = false

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
		is_draggable = false
		set_translucent(false)
		ball_exited.emit()
		print("Ball exited ", name, ", is_draggable: ", is_draggable)

func _on_visibility_changed() ->void:
	print("Vis Changed")
	move_area.monitorable = visible
	move_area.monitoring = visible

func set_translucent(active:bool) ->void:
	print("Setting Translucent!!")
	modulate.a = TRANSLUCENT_VALUE if active else 1.0

func _reset() ->void:
	global_position = start_position
