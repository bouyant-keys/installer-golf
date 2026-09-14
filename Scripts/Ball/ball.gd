class_name Ball extends CharacterBody2D

const Z_INDEX_OFFSET := 2
const DECEL_RATE := 50.0
const EDGE_MARGIN := 6.0
const CHECK_DIST := 16.0
const STRENGTH_RANGE := Vector2(30.0, 600.0)
const DRAG_MIN := Vector2(5.0, 5.0)
const DRAG_MAX := 160.0 # Furthest distance in pixels to drag for a shot, means the maximum strength is applied
const BALL_SIZE := Vector2(16.0, 16.0)

var start_local_pos : Vector2
var relative_pos_ratio : Vector2 # Used with resizable windows - keep the same normalized position when resized
var move_dir := Vector2.ZERO
var local_position : Vector2
var current_speed : float = 0.0
var current_window : WindowPanel
var prev_window : WindowPanel
#var in_windows : Array[WindowPanel]
var mouse_hover := false
var mouse_drag := false
var click_pos : Vector2
var frozen := false
var launched := false
var can_launch := true # Disabled if ball entered in collision shape.

@export var start_window : WindowPanel
@export var window_manager : WindowManager
@export var enter_on_load := true

@onready var floor_area: FloorArea = $FloorArea
@onready var start_area: Area2D = $StartArea
@onready var trajectory: Line2D = $Trajectory
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var bounce_sfx: AudioStreamPlayer = $BounceSFX
@onready var bounce_sfx_2: AudioStreamPlayer = $BounceSFX2
@onready var launch_sfx: AudioStreamPlayer = $LaunchSFX
@onready var land_sfx: AudioStreamPlayer = $LandSFX
@onready var rolling_sfx: AudioStreamPlayer = $RollingSFX
@onready var enter_sfx: AudioStreamPlayer = $EnterSFX
@onready var exit_sfx: AudioStreamPlayer = $ExitSFX
@onready var fall_sfx: AudioStreamPlayer = $FallSFX

@onready var ball_collider: CollisionShape2D = $BallCollider
@onready var mouse_area_collider: CollisionShape2D = $MouseArea/MouseAreaCollider
@onready var fall_area_collider: CollisionShape2D = $FallArea/FallAreaCollider

signal current_window_changed(window:WindowPanel)
signal trajectory_changed(trajectory:Vector2, strength:float)
signal draw_trajectory(enabled:bool)
signal direction_changed(at_pos:Vector2)
signal ball_launched
signal ball_stopped
signal ball_entered
signal ball_fell
signal ball_exited

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	
	window_manager.child_window_selected.connect(_on_window_selected)
	window_manager.child_window_grabbed.connect(_on_window_grabbed)
	window_manager.child_window_released.connect(_on_window_released)
	window_manager.child_window_resize_start.connect(_on_window_resize_start)
	window_manager.child_window_resized.connect(_on_window_resized)
	window_manager.child_window_resize_end.connect(_on_window_resize_end)
	current_window_changed.connect(window_manager._on_current_window_changed)
	
	start_local_pos = global_position - start_window.global_position
	
	set_collision_active(false)
	hide()


func enter() ->void:
	anim.play("enter")
	enter_sfx.play()
	show()
	
	await anim.animation_finished
	set_collision_active(true)
	set_process(true)
	set_physics_process(true)
	ball_entered.emit()

func fall() ->void:
	velocity = Vector2.ZERO
	set_collision_active(false, false)
	set_process(false)
	set_physics_process(false)
	anim.play("fall")
	fall_sfx.play()
	
	await anim.animation_finished
	ball_fell.emit()
	_on_stage_reset()

func exit() ->void:
	anim.play("exit")
	exit_sfx.play()
	ball_exited.emit()
	
	await anim.animation_finished
	hide()


func _input(event: InputEvent) -> void:
	if launched or !can_launch or frozen:
		return
	
	if event.is_action_pressed("LeftClick") && mouse_hover:
		mouse_drag = true
		click_pos = get_global_mouse_position()
		draw_trajectory.emit(true)
		get_viewport().set_input_as_handled()
	elif event.is_action_released("LeftClick") && mouse_drag:
		mouse_drag = false
		var launch_dir := -(get_global_mouse_position() - click_pos)
		if abs(launch_dir) < DRAG_MIN:
			return
		
		move_dir = launch_dir.normalized()
		direction_changed.emit(global_position)
		
		var launch_strength := clampf(launch_dir.length(), STRENGTH_RANGE.x, STRENGTH_RANGE.y)
		current_speed = launch_strength
		launched = true
		draw_trajectory.emit(false)
		launch_sfx.play()
		ball_launched.emit()


func _process(_delta: float) ->void:
	if !mouse_drag:
		return
	
	var launch_dir := -(get_global_mouse_position() - click_pos)
	var launch_strength := clampf(launch_dir.length(), STRENGTH_RANGE.x, STRENGTH_RANGE.y)
	trajectory_changed.emit(launch_dir, launch_strength)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var curr_window := get_current_window()
	if !launched:
		# Follow window position if window is movable.
		global_position = curr_window.get_movable_area().position + local_position
		return
	elif frozen:
		print("Frozen!!")
		global_position = curr_window.get_movable_area().position + local_position
		return
	
	if is_zero_approx(current_speed):
		ball_stopped.emit()
	
	var move_rect := get_current_window().get_movable_area()
	
	# Calculate ball's next position from their speed & direction
	current_speed = move_toward(current_speed, 0.0, DECEL_RATE * delta)
	var current_velocity := move_dir * current_speed * delta
	
	# Update next_pos with potentially changed values, & assign to global position.
	velocity = current_velocity
	local_position += current_velocity
	global_position = local_position + move_rect.position
	
	var collision := move_and_collide(velocity)
	if collision:
		move_dir = move_dir.bounce(collision.get_normal())
		on_bounce()


func get_current_window() ->WindowPanel:
	return current_window

func set_current_window(window:WindowPanel) ->void:
	if current_window:
		print("Landed on new window: ", window, "!")
		prev_window = current_window
		anim.play("land")
		land_sfx.play()
	
	current_window = window
	if current_window is ResizableWindow:
		relative_pos_ratio = global_position / current_window.get_rect().end
	z_index = current_window.z_index + Z_INDEX_OFFSET
	local_position = global_position - current_window.get_move_area_position()
	current_window_changed.emit(window)

func set_collision_active(active:bool, include_body:bool = true) ->void:
	#print("--Collision set: ", active, ", ", include_body)
	if include_body:
		ball_collider.set_deferred("disabled", !active)
	mouse_area_collider.set_deferred("disabled", !active)
	floor_area.set_area_enabled(active)
	fall_area_collider.set_deferred("disabled", !active)


func on_bounce() ->void:
	if randf() > 0.5:
		bounce_sfx.play()
	else:
		bounce_sfx_2.play()
	
	direction_changed.emit(global_position)


func _on_valid_spot() ->void: can_launch = true
func _on_invalid_spot() ->void: can_launch = false

func _on_fall_area_entered(_area: Area2D) -> void:  if launched: fall()

func on_mouse_entered() ->void: mouse_hover = true
func on_mouse_exited() ->void: mouse_hover = false

#region WindowSignals
func _on_window_selected(window:WindowPanel) ->void:
	var curr_window := get_current_window()
	if curr_window == window:
		z_index = curr_window.z_index

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
	
	if launched:
		frozen = true
		set_collision_active(false)
	relative_pos_ratio = global_position / current_window.get_rect().end

func _on_window_resized(window:WindowPanel) ->void:
	if get_current_window() != window:
		return
	
	global_position = relative_pos_ratio * get_current_window().get_rect().end

func _on_window_resize_end(window:WindowPanel) ->void:
	if get_current_window() != window:
		return
	if launched:
		frozen = false
		set_collision_active(true)
#endregion

func _on_goal() ->void:
	print("Ball hit goal!")
	current_speed = 0.0
	velocity = Vector2.ZERO
	move_dir = Vector2.ZERO
	floor_area.set_area_enabled(false)
	exit()

func _on_stage_reset() ->void:
	print("Ball reset.")
	frozen = false
	launched = false
	current_speed = 0.0
	floor_area.in_windows.clear()
	velocity = Vector2.ZERO
	move_dir = Vector2.ZERO
	global_position = start_local_pos + start_window.global_position
	set_collision_active(false)
	
	await get_tree().process_frame
	set_current_window(start_window)
	enter()
