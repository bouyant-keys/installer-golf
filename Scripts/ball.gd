class_name Ball extends CharacterBody2D

const Z_INDEX_OFFSET := 0
const DECEL_RATE := 50.0
const EDGE_MARGIN := 6.0
const CHECK_DIST := 16.0
const STRENGTH_RANGE := Vector2(30.0, 600.0)
const DRAG_MAX := 160.0 # Furthest distance in pixels to drag for a shot, means the maximum strength is applied
const BALL_SIZE := Vector2(16.0, 16.0)

var start_position : Vector2
var move_dir := Vector2.ZERO
var local_position : Vector2
var current_speed : float = 0.0
var current_window : WindowPanel
var prev_window : WindowPanel
var in_windows : Array[WindowPanel]
var on_bounce_margin : float
var mouse_hover := false
var mouse_drag := false
var click_pos : Vector2
var frozen := false
var launched := false
var fell_out := false

#@export var randomize_start_direction := false
#@export var initial_direction := Vector2(1.0, -0.75)
@export var start_window : WindowPanel
@export var window_manager : WindowManager
@export var enter_on_load := true

@onready var floor_area: Area2D = $FloorArea
@onready var trajectory: Line2D = $Trajectory
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var bounce_sfx: AudioStreamPlayer = $BounceSFX
@onready var bounce_sfx_2: AudioStreamPlayer = $BounceSFX2
@onready var launch_sfx: AudioStreamPlayer = $LaunchSFX
@onready var land_sfx: AudioStreamPlayer = $LandSFX
@onready var fall_sfx: AudioStreamPlayer = $FallSFX

@onready var ball_collider: CollisionShape2D = $BallCollider
@onready var mouse_area_collider: CollisionShape2D = $MouseArea/MouseAreaCollider
@onready var floor_area_collider: CollisionShape2D = $FloorArea/FloorAreaCollider
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
	window_manager.window_selected.connect(_on_window_selected)
	window_manager.window_grabbed.connect(_on_window_grabbed)
	window_manager.window_released.connect(_on_window_released)
	current_window_changed.connect(window_manager._on_current_window_changed)
	
	start_position = global_position
	hide()
	
	# Only disabled for intro level
	if enter_on_load:
		enter()

func enter() ->void:
	show()
	set_current_window(start_window)
	anim.play("enter")
	
	await anim.animation_finished
	set_collision_active(true)
	set_process(true)
	set_physics_process(true)
	ball_entered.emit()

func fall() ->void:
	fell_out = true
	velocity = Vector2.ZERO
	set_collision_active(false, false)
	set_process(false)
	set_physics_process(false)
	anim.play("fall")
	fall_sfx.play()
	
	await anim.animation_finished
	ball_fell.emit()
	_on_stage_reset()
	enter()

func exit() ->void:
	anim.play("exit")
	ball_exited.emit()
	
	await anim.animation_finished
	hide()

func _input(event: InputEvent) -> void:
	if launched:
		return
	
	if event.is_action_pressed("LeftClick") && mouse_hover:
		mouse_drag = true
		click_pos = get_global_mouse_position()
		draw_trajectory.emit(true)
	elif event.is_action_released("LeftClick") && mouse_drag:
		mouse_drag = false
		var launch_dir := -(get_global_mouse_position() - click_pos)
		move_dir = launch_dir.normalized()
		direction_changed.emit(global_position)
		
		var launch_strength := clampf(launch_dir.length(), STRENGTH_RANGE.x, STRENGTH_RANGE.y)
		current_speed = launch_strength
		launched = true
		draw_trajectory.emit(false)
		ball_launched.emit()
		#print("Released, Pos: ", release_pos, ", Distance: ", release_pos - click_pos)

func _process(_delta: float) ->void:
	if !mouse_drag:
		return
	
	var launch_dir := -(get_global_mouse_position() - click_pos)
	var launch_strength := clampf(launch_dir.length(), STRENGTH_RANGE.x, STRENGTH_RANGE.y)
	trajectory_changed.emit(launch_dir, launch_strength)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !launched:
		return
	elif !current_window:
		fell_out = true
		return
	elif frozen:
		print("Frozen!!")
		global_position = current_window.get_movable_area().position + local_position
		return
	elif fell_out:
		fall()
		return
	
	if is_zero_approx(current_speed):
		ball_stopped.emit()
	
	var move_rect := current_window.get_movable_area()
	# Calculate character's next position from their speed & direction
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
	z_index = current_window.z_index + Z_INDEX_OFFSET
	local_position = global_position - current_window.get_move_area_position()
	current_window_changed.emit(window)

func set_collision_active(active:bool, include_body:bool = true) ->void:
	if include_body:
		ball_collider.set_deferred("disabled", !active)
	mouse_area_collider.set_deferred("disabled", !active)
	floor_area_collider.set_deferred("disabled", !active)
	fall_area_collider.set_deferred("disabled", !active)

func check_valid_window() ->WindowPanel:
	var enter_window : WindowPanel = null
	var overlap_windows := window_manager.get_windows_at_position(global_position)
	for window : WindowPanel in overlap_windows:
		if !enter_window:
			if window.z_index < z_index:
				enter_window = window
		else:
			if window.z_index > enter_window.z_index and window.z_index < z_index:
				enter_window = window
	
	return enter_window

func on_bounce() ->void:
	if randf() > 0.5:
		bounce_sfx.play()
	else:
		bounce_sfx_2.play()
	
	direction_changed.emit(global_position)

func add_to_window_list(window:WindowPanel) ->void:
	if window == current_window or in_windows.has(window):
		return
	
	in_windows.append(window)
	print(window.name + " added to in_windows. Size: ", in_windows.size())

func _on_movable_area_entered(area: Area2D) -> void:
	if area is GoalArea:
		_on_goal()
		return
	elif area is not MoveArea:
		return
	
	var move_area := area as MoveArea
	var window := move_area.get_window_panel()
	
	if !get_current_window():
		set_current_window(window)
		set_process(true)
	else:
		add_to_window_list(window)
	
	#print(" -- AreaEntered -- ", window.name, ", CurrentWindow: ", current_window,", in_windows: ", in_windows, "\n")
func _on_movable_area_exited(area: Area2D) -> void:
	if floor_area_collider.disabled: # Problematic ?
		return
	elif area is not MoveArea:
		return
	
	var move_area := area as MoveArea
	var window := move_area.get_window_panel()
	print("Ball exited " + window.name + ".")
	
	if window == current_window:
		print("Exiting current window!!!")
		var valid_window := check_valid_window()
		if !valid_window:
			fell_out = true
			return
		else:
			set_current_window(valid_window)
			#in_windows.remove_at(0)
			print(window.name + " set as current_window. in_windows size: ", in_windows.size())
	else:
		in_windows.erase(window)
		print(window.name + " removed from in_windows. Size: ", in_windows.size())


func _on_fall_area_entered(_area: Area2D) -> void:
	fall()

func on_mouse_entered() ->void:
	mouse_hover = true
func on_mouse_exited() ->void:
	mouse_hover = false

func _on_window_selected(window:WindowPanel) ->void:
	if current_window == window:
		z_index = current_window.z_index

func _on_window_grabbed(window:WindowPanel) ->void:
	if get_current_window() != window:
		return
	elif in_windows.has(window):
		set_current_window(window)
	frozen = true
	floor_area.monitoring = false
	floor_area.monitorable = false
func _on_window_released(window:WindowPanel) ->void:
	if get_current_window() != window:
		return
	frozen = false
	floor_area.monitoring = true
	floor_area.monitorable = true


func _on_goal() ->void:
	print("Ball hit goal!")
	current_speed = 0.0
	velocity = Vector2.ZERO
	move_dir = Vector2.ZERO
	floor_area_collider.set_deferred("disabled", true)
	exit()

func _on_stage_reset() ->void:
	print("Ball reset.")
	frozen = false
	launched = false
	fell_out = false
	current_speed = 0.0
	in_windows.clear()
	velocity = Vector2.ZERO
	move_dir = Vector2.ZERO
	global_position = start_position
	set_collision_active(false)
	
	await get_tree().process_frame
	enter()
