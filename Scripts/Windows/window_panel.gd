class_name WindowPanel extends Control

const DOWNLOAD_ICON = preload("uid://3draj3d7o7c1")
const GOAL_ICON = preload("uid://die2augvrkvo8")
const TUTORIAL_ICON = preload("uid://w1n4taqaa3gn")
const RESIZE_ICON = preload("uid://c7t72mo374dvy")
const TAB_ICON = preload("uid://myile0scxfs3")
const ERROR_ICON = preload("uid://bkd432rkvigtf")

const BOUNDS_NUDGE_MIN := Vector2(4.0, 24.0)
const BOUNDS_NUDGE_MAX := Vector2(64.0, 24.0)
const TITLE_FORMAT := &"Installer"
const TUTORIAL_TITLE := &"Guide"
const ERROR_TITLE := &"!! ERROR !!"
const ENTER_TIME := 0.4
const EXIT_TIME := 0.4
const BOUNCE_TIME := 0.25

enum ICON_TYPE {DOWNLOAD, GOAL, TUTORIAL, ERROR, TAB, RESIZABLE}

var is_selected := false
var start_position : Vector2
var move_start : Vector2
var drag_start : Vector2
var is_draggable := true
var grabbable := false
var dragging := false
var has_exited := false

## Which Icon to use for the window (upper left corner).
@export var window_icon := ICON_TYPE.DOWNLOAD
## Allow window to enter on stage start when called by the Window Manager. (Otherwise enter() must be called from somewhere else)
@export var enter_on_start := true
## Show lock icon on window grab bar & prevent window moving with clicking & dragging the mouse.
@export var is_locked := false
## Orders window above all non-error windows.
@export var is_error := false
## Text to use as window title inside the grab bar.
@export var title_text : StringName
## Color for grab bar background
@export var grab_bar_color : Color = Color(0.0, 0.0, 0.502)
## Allow window to be closed with the 'X' button in the left-corner.
@export var closable := false

@onready var panel_parent: Control = %PanelParent # Node that is tweened on enter / exit
@onready var grab_bar: PanelContainer = %GrabBar
@onready var window_title: Label = %WindowTitle
@onready var lock_icon: TextureRect = %LockIcon
@onready var move_area: MoveArea = %MoveArea
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var icon_texture: TextureRect = %IconTexture
@onready var selected_outline: ColorRect = %SelectedOutline

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
	
	if is_error:
		window_title.text = ERROR_TITLE
	elif window_icon == ICON_TYPE.TUTORIAL:
		window_title.text = TUTORIAL_TITLE if title_text.is_empty() else title_text
	else:
		window_title.text = name if title_text.is_empty() else title_text
	
	selected_outline.hide()
	set_icon(window_icon)
	set_locked(is_locked)
	set_children_visibility(false)

func _gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		grab()
	elif Input.is_action_pressed("LeftClick") and dragging:
		global_position = move_start + (get_global_mouse_position() - drag_start)
	elif Input.is_action_just_released("LeftClick"):
		release()

## Called when the window pops into the scene at the start of the stage.
func enter() ->void:
	panel_parent.show()
	panel_parent.scale = Vector2.ZERO
	panel_parent.pivot_offset_ratio = Vector2(0.5, 0.5)
	enter_sfx.play()
	
	var enter_tween := get_tree().create_tween()
	enter_tween.tween_property(panel_parent, "scale", Vector2.ONE, ENTER_TIME)
	
	await enter_tween.finished
	has_exited = false
	entered.emit()
	move_area.set_collider_active(true)
	set_children_visibility(true)

## Called when the window shrinks from the scene at the end of the stage.
func exit() ->void:
	set_children_visibility(false)
	panel_parent.show()
	panel_parent.scale = Vector2.ONE
	panel_parent.pivot_offset_ratio = Vector2(0.5, 0.5)
	exit_sfx.play()
	
	var exit_tween := get_tree().create_tween()
	exit_tween.tween_property(panel_parent, "scale", Vector2.ZERO, EXIT_TIME)
	
	await exit_tween.finished
	has_exited = true
	exited.emit()
	move_area.set_collider_active(false)


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
	
	window_released.emit(self)

func close() ->void:
	if !closable: return
	
	await exit()
	window_closed.emit()
	global_position = start_position
	enter()


func bounce(direction:Vector2, force:float) ->void:
	var final_pos := global_position + (-direction * (force))
	print("Force: ", force)
	
	panel_parent.global_position = final_pos
	var bounce_tween := get_tree().create_tween()
	bounce_tween.tween_property(panel_parent, "global_position", global_position, BOUNCE_TIME).set_trans(Tween.TRANS_BACK)


func set_children_visibility(active:bool) ->void:
	for child : Node in get_children():
		if child is StaticObstacle:
			continue
		elif child is Node2D:
			child.visible = active
		elif child is Control:
			if child == selected_outline:
				continue
			child.visible = active

func set_icon(icon:ICON_TYPE) ->void:
	match icon:
		ICON_TYPE.DOWNLOAD:
			icon_texture.texture = DOWNLOAD_ICON
		ICON_TYPE.GOAL:
			icon_texture.texture = GOAL_ICON
		ICON_TYPE.TUTORIAL:
			icon_texture.texture = TUTORIAL_ICON
		ICON_TYPE.ERROR:
			icon_texture.texture = ERROR_ICON
		ICON_TYPE.TAB:
			icon_texture.texture = TAB_ICON
		ICON_TYPE.RESIZABLE:
			icon_texture.texture = RESIZE_ICON

func set_z_order(z:int) ->void:
	z_index = z
	reordered.emit(z)

func set_locked(locked:bool) ->void:
	is_locked = locked
	lock_icon.visible = locked
	grab_bar.mouse_default_cursor_shape = Control.CURSOR_ARROW if is_locked else Control.CURSOR_DRAG
	set_process_input(!locked)


func get_movable_area() ->Rect2: return move_area.get_movable_area()
func get_move_area_position() ->Vector2: return move_area.get_collider_position()


func _on_grab_bar_entered() ->void: 
	selected_outline.show()
	grabbable = true
func _on_grab_bar_exited() ->void: 
	selected_outline.hide()
	grabbable = false

func _on_new_current_window(_c_window:WindowPanel) ->void:
	return
	#if c_window == self:
		#ball_entered.emit()
	#else:
		#ball_exited.emit()

func _on_move_area_entered(area:Area2D) -> void:
	if area is not FloorArea:
		return
	is_draggable = false
	ball_entered.emit()
	print("Ball entered ", name, ", WindowZ: ", z_index, ", BallZ: ", area.z_index)

func _on_move_area_exited(area:Area2D) -> void:
	if area is not FloorArea:
		return
	is_draggable = true
	ball_exited.emit()
	print("Ball exited ", name, ", is_draggable: ", is_draggable)

func _reset() ->void:
	global_position = start_position
