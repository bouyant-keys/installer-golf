class_name Ball extends CharacterBody2D

const RESET_Z := 10
const DECEL_RATE := 50.0
const STRENGTH_RANGE := Vector2(80.0, 600.0)
const DRAG_MIN := Vector2(5.0, 5.0)

var start_pos : Vector2
var click_pos : Vector2
var move_dir := Vector2.ZERO
var local_position : Vector2
var current_speed : float = 0.0
var current_window : WindowPanel
var prev_window : WindowPanel
var mouse_hover := false
var mouse_drag := false
var entered := false
var frozen := false
var stopped := false
var launched := false
var can_launch := false # Disabled if ball entered in collision shape.
var resizing := false

@export var window_manager : WindowManager
@export var enter_on_load := true
@export var special := false

@onready var floor_area: FloorArea = $FloorArea
@onready var trajectory: Line2D = $Trajectory
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var mouse_control: Control = $MouseCursorControl
@onready var bounce_sfx: AudioStreamPlayer = $BounceSFX
@onready var bounce_sfx_2: AudioStreamPlayer = $BounceSFX2
@onready var launch_sfx: AudioStreamPlayer = $LaunchSFX
@onready var land_sfx: AudioStreamPlayer = $LandSFX
@onready var rolling_sfx: AudioStreamPlayer = $RollingSFX
@onready var enter_sfx: AudioStreamPlayer = $EnterSFX
@onready var exit_sfx: AudioStreamPlayer = $ExitSFX
@onready var fall_sfx: AudioStreamPlayer = $FallSFX
@onready var stuck_sfx: AudioStreamPlayer = $StuckSFX

@onready var ball_collider: CollisionShape2D = $BallCollider
@onready var mouse_area_collider: CollisionShape2D = $MouseArea/MouseAreaCollider
@onready var fall_area_collider: CollisionShape2D = $FallArea/FallAreaCollider

signal current_window_changed(window:WindowPanel)
signal trajectory_changed(trajectory:Vector2, strength:float, strength_range:Vector2)
signal draw_trajectory(enabled:bool)
signal direction_changed(at_pos:Vector2)
signal ball_launched
signal ball_stopped
signal ball_stuck
signal ball_fell
signal ball_entered
signal ball_exited
signal ball_reset

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	
	# Connect to ball:
	window_manager.child_window_selected.connect(_on_window_selected)
	window_manager.child_window_grabbed.connect(_on_window_grabbed)
	window_manager.child_window_released.connect(_on_window_released)
	window_manager.child_window_resize_start.connect(_on_window_resize_start)
	window_manager.child_window_resized.connect(_on_window_resized)
	window_manager.child_window_resize_end.connect(_on_window_resize_end)
	
	# Connect from ball:
	current_window_changed.connect(window_manager._on_current_window_changed)
	
	start_pos = global_position
	z_index = RESET_Z
	set_collision_active(false)
	hide()

## Played when ball enters the stage.
func enter() ->void:
	anim.play("enter")
	enter_sfx.play()
	show()
	
	await anim.animation_finished
	entered = true
	mouse_control.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	set_collision_active(true)
	set_process(true)
	set_physics_process(true)
	ball_entered.emit()

## Played when ball finds itself stuck inside a collision obstacle and must reset.
func stuck() ->void:
	print("Ball Stuck")
	set_current_window(null)
	mouse_control.mouse_default_cursor_shape = Control.CURSOR_ARROW
	velocity = Vector2.ZERO
	set_collision_active(false)
	set_process(false)
	set_physics_process(false)
	anim.play("stuck")
	rolling_sfx.stop()
	stuck_sfx.play()
	
	await anim.animation_finished
	ball_stuck.emit()
	_on_stage_reset()

## Played when ball falls outside a window into the background and must reset.
func fall() ->void:
	print("Ball Fell")
	set_current_window(null)
	mouse_control.mouse_default_cursor_shape = Control.CURSOR_ARROW
	velocity = Vector2.ZERO
	set_collision_active(false)
	set_process(false)
	set_physics_process(false)
	anim.play("fall")
	rolling_sfx.stop()
	fall_sfx.play()
	
	await anim.animation_finished
	ball_fell.emit()
	_on_stage_reset()

## Played when ball reaches the goal.
func exit() ->void:
	anim.play("exit")
	rolling_sfx.stop()
	exit_sfx.play()
	ball_exited.emit()
	
	await anim.animation_finished
	hide()


func _input(event: InputEvent) -> void:
	if !stopped and (launched or !can_launch or frozen or !entered):
		return
	
	if event.is_action_pressed("LeftClick") && mouse_hover:
		if stopped:
			_on_stage_reset()
			return
		mouse_drag = true
		click_pos = get_global_mouse_position()
		draw_trajectory.emit(true)
		get_viewport().set_input_as_handled()
	elif event.is_action_released("LeftClick") && mouse_drag:
		if !get_current_window():
			var new_window := floor_area.recheck_current_window()
			set_current_window(new_window)
		
		mouse_drag = false
		var launch_dir := -(get_global_mouse_position() - click_pos)
		if abs(launch_dir) < DRAG_MIN:
			return
		
		move_dir = launch_dir.normalized()
		local_position = global_position - current_window.get_move_area_position()
		direction_changed.emit(global_position)
		
		var launch_strength := clampf(launch_dir.length(), STRENGTH_RANGE.x, STRENGTH_RANGE.y)
		current_speed = launch_strength
		launched = true
		draw_trajectory.emit(false)
		launch_sfx.play()
		rolling_sfx.play()
		ball_launched.emit()


func _process(_delta: float) ->void:
	if !mouse_drag:
		return
	
	var launch_dir := -(get_global_mouse_position() - click_pos)
	var launch_strength := clampf(launch_dir.length(), STRENGTH_RANGE.x, STRENGTH_RANGE.y)
	trajectory_changed.emit(launch_dir, launch_strength, STRENGTH_RANGE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !launched or stopped or frozen:
		return
	
	var move_rect := get_current_window().get_movable_area()
	
	# Decelerate ball over time by DECEL_RATE
	if !special:
		current_speed = move_toward(current_speed, 0.0, DECEL_RATE * delta)
	
	if is_zero_approx(current_speed):
		print("Ball stopped!")
		stopped = true
		rolling_sfx.stop()
		ball_stopped.emit()
	
	var current_velocity := move_dir * current_speed * delta
	
	# Update next_pos with potentially changed values, & assign to global position.
	velocity = current_velocity
	local_position += current_velocity
	global_position = local_position + move_rect.position
	
	handle_collision(move_and_collide(velocity))

func handle_collision(collision:KinematicCollision2D) ->void:
	if !collision: return
	
	move_dir = move_dir.bounce(collision.get_normal())
	get_current_window().bounce(collision.get_normal(), velocity.length())
	direction_changed.emit(global_position)
	
	if randf() > 0.5: 
		if !bounce_sfx.playing: bounce_sfx.play()
		else: bounce_sfx_2.play()
	else:
		if !bounce_sfx_2.playing: bounce_sfx_2.play()
		else: bounce_sfx.play()
	


func get_current_window() ->WindowPanel:
	return current_window

func set_current_window(window:WindowPanel) ->void:
	print("SetCurrentWindow: ", window)
	
	if !window:
		current_window = null
		current_window_changed.emit(null)
		return
	
	if current_window:
		print("Landed on new window: ", window, "!")
		prev_window = current_window
		anim.play("land")
		land_sfx.play()
	
	current_window = window
	local_position = global_position - current_window.get_move_area_position()
	current_window_changed.emit(window)

func set_collision_active(active:bool) ->void:
	#print("--Collision set: ", active)
	ball_collider.set_deferred("disabled", !active)
	#mouse_area_collider.set_deferred("disabled", !active)
	fall_area_collider.set_deferred("disabled", !active)


func _on_valid_spot() ->void: can_launch = true
func _on_invalid_spot() ->void: can_launch = false

func _on_fall_area_entered(_area: Area2D) -> void:  if launched: fall()

func on_mouse_entered() ->void: mouse_hover = true
func on_mouse_exited() ->void: mouse_hover = false

#region WindowSignals
func _on_window_selected(_window:WindowPanel) ->void: pass

func _on_window_grabbed(window:WindowPanel) ->void:
	if get_current_window() != window:
		return
	elif floor_area.in_windows.has(window):
		set_current_window(window)
	
	frozen = true
	set_collision_active(false)

func _on_window_released(window:WindowPanel) ->void:
	if get_current_window() != window:
		return
	
	frozen = false
	set_collision_active(true)

func _on_window_resize_start(window:WindowPanel) ->void:
	if get_current_window() != window:
		return
	
	resizing = true
	frozen = true
	set_collision_active(false)

func _on_window_resized(_window:WindowPanel) ->void: pass

func _on_window_resize_end(window:WindowPanel) ->void:
	if get_current_window() != window:
		return
	resizing = false
	frozen = false
	set_collision_active(true)
#endregion

func _on_goal() ->void:
	print("Ball hit goal!")
	current_speed = 0.0
	mouse_control.mouse_default_cursor_shape = Control.CURSOR_ARROW
	velocity = Vector2.ZERO
	move_dir = Vector2.ZERO
	floor_area.set_area_enabled(false)
	set_physics_process(false)
	exit()

func _on_stage_reset() ->void:
	print("Ball reset.")
	frozen = false
	stopped = false
	launched = false
	entered = false
	current_speed = 0.0
	floor_area.in_windows.clear()
	mouse_control.mouse_default_cursor_shape = Control.CURSOR_ARROW
	velocity = Vector2.ZERO
	move_dir = Vector2.ZERO
	global_position = start_pos
	z_index = RESET_Z
	rolling_sfx.stop()
	set_collision_active(false)
	ball_reset.emit()
	
	await get_tree().process_frame
	enter()
