class_name Ball extends CharacterBody2D

const DECEL_RATE := 50.0
const EDGE_MARGIN := 6.0
const STRENGTH_RANGE := Vector2(30.0, 600.0)
const DRAG_MAX := 160.0 # Furthest distance in pixels to drag for a shot, means the maximum strength is applied
const BALL_SIZE := Vector2(16.0, 16.0)

var move_dir := Vector2.ZERO
var local_position : Vector2
var current_speed : float = 0.0
var current_window : WindowPanel
var in_windows : Array[WindowPanel]
var bounce_margin : float
var mouse_hover := false
var mouse_drag := false
var click_pos : Vector2
var frozen := false
var launched := false

#@export var randomize_start_direction := false
#@export var initial_direction := Vector2(1.0, -0.75)
@export var start_position : Control
@export var window_manager : WindowManager

@onready var ball_area: Area2D = $BallArea
@onready var trajectory: Line2D = $Trajectory
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var bounce_sfx: AudioStreamPlayer = $BounceSFX
@onready var bounce_sfx_2: AudioStreamPlayer = $BounceSFX2
@onready var launch_sfx: AudioStreamPlayer = $LaunchSFX

signal trajectory_changed(trajectory:Vector2, strength:float)
signal draw_trajectory(enabled:bool)
signal direction_changed(at_pos:Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	window_manager.window_grabbed.connect(_on_window_grabbed)
	window_manager.window_released.connect(_on_window_released)
	
	global_position = start_position.global_position
	launched = false

func _input(event: InputEvent) -> void:
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
	elif frozen:
		print("Frozen!!")
		global_position = current_window.get_movable_area().position + local_position
		return
	elif !check_in_movable_areas():
		#print("Ball not in an area! ", global_position)
		return
	
	var current_movable_area := get_current_window().get_movable_area()
	
	# Calculate character's next position from their speed & direction
	current_speed = move_toward(current_speed, 0.0, DECEL_RATE * delta)
	var current_velocity := move_dir * current_speed * delta
	var next_pos := local_position + current_velocity
	
	# Check whether the next position is within an intersection of multiple windows (ignoring bounds[0]):
	#var in_intersection : bool
	#if in_windows.size() == 0:
		## if character is only in current_window, there's no chance of being in an intersecting area
		#in_intersection = false
	#else:
		#var global_next_pos := next_pos + current_movable_area.position
		#in_intersection = check_in_window_intersection(global_next_pos)
		#print("In_Intersection: ", in_intersection)
	
	#if current_movable_area.has_point(next_pos):
		#pass
	#else:
		#var bounce := true
		#for window : WindowPanel in window_manager.windows:
			#if window.get_movable_area().has_point(next_pos):
				#var next_window := window
				#if next_window.get_movable_area().intersects(current_movable_area):
					#bounce = false
					#break
		#if bounce:
			#pass
	
	
	# Restrain character inside bounds based on min & max pos,
	# otherwise use the previous local window position by default.
	var clamp_pos := local_position
	if in_windows.is_empty():
		# If not in an intersection: enforce bounaries, update move_dir, & update clamp position
		# otherwise: ignore bounds and allow character to pass (don't change move_dir or clamp next_pos).
		var min_pos := Vector2(EDGE_MARGIN, EDGE_MARGIN)
		var max_pos := current_movable_area.size - Vector2(EDGE_MARGIN, EDGE_MARGIN)
		#print("LocalPos: ", local_position, ", Min_pos: ", min_pos, ", Max_pos: ", max_pos)
		if next_pos.x < min_pos.x:
			print("Out of bounds: Min X ", min_pos.x)
			move_dir = move_dir.bounce(Vector2.RIGHT)
			clamp_pos.x = min_pos.x
		elif next_pos.x > max_pos.x:
			print("Out of bounds: Max X ", max_pos.x)
			move_dir = move_dir.bounce(Vector2.RIGHT)
			clamp_pos.x = max_pos.x
		
		if next_pos.y < min_pos.y:
			print("Out of bounds: Min Y ", min_pos.y)
			move_dir = move_dir.bounce(Vector2.UP)
			clamp_pos.y = min_pos.y
		elif next_pos.y > max_pos.y:
			print("Out of bounds: Max Y ", max_pos.y)
			move_dir = move_dir.bounce(Vector2.UP)
			clamp_pos.y = max_pos.y
		
	
	if !clamp_pos.is_equal_approx(local_position):
		print("Bounce - ClampPos: ", clamp_pos, ", LocalPos: ", local_position)
		current_velocity = move_dir * current_speed * delta
		bounce()
	
	# Update next_pos with potentially changed values, & assign to global position.
	#print("Clamp: ",clamp_pos)
	velocity = current_velocity
	local_position = clamp_pos + current_velocity
	global_position = local_position + current_movable_area.position
	
	var collision := move_and_collide(velocity)
	if collision:
		print("Ball Collided at ", collision.get_position())
		move_dir = move_dir.bounce(collision.get_normal())
		bounce()

func check_in_movable_areas() ->bool:
	var in_movable_area := false
	
	var movable_areas : Array[MoveArea]
	for area in ball_area.get_overlapping_areas():
		if area is MoveArea:
			movable_areas.append(area as MoveArea)
	
	in_movable_area = movable_areas.size() > 0
	
	if in_movable_area && !get_current_window():
		set_current_window(movable_areas[0].get_window_panel())
	
	return in_movable_area

## Returns true if [param pos] is within the shape of any one of the Rect2s in [param bounds].
#func check_in_window_intersection(pos:Vector2) ->bool:
	#var overlap_pos := false
	#for i : int in in_windows.size():
		#if in_windows[i].get_rect().has_point(pos):
			#overlap_pos = true
			#print("Overlapping with: ", in_windows[i].name)
			#break
	#return overlap_pos


func get_current_window() ->WindowPanel:
	#if !current_window:
		#return null
	#elif in_windows.size() == 0:
		#return current_window
	
	#for window : WindowPanel in in_windows:
		#if window.is_selected:
			#add_to_window_list(current_window)
			#set_current_window(window)
			#break
	
	return current_window

func set_current_window(window:WindowPanel) ->void:
	current_window = window
	local_position = global_position - current_window.get_movable_area().position

## Returns a normalized Vector2 with a random (positive or negative) orientation.
func get_random_direction() ->Vector2:
	var rand_rot : float = randf_range(0.0, TAU)
	return Vector2.ONE.rotated(rand_rot).normalized()

func bounce() ->void:
	print("Bounced!")
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

func _on_ball_area_entered(area: Area2D) -> void:
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
	
	print(" -- AreaEntered -- ", window.name, ", CurrentWindow: ", current_window,", in_windows: ", in_windows, "\n")
func _on_ball_area_exited(area: Area2D) -> void:
	if area is not MoveArea:
		return
	
	var move_area := area as MoveArea
	var window := move_area.get_window_panel()
	print("Ball exited " + window.name + ".")
	
	if window == get_current_window():
		print("Exiting current window!!!")
		if in_windows.size() == 0:
			printerr("Character out of bounds!")
			return
		else:
			set_current_window(in_windows[0])
			in_windows.remove_at(0)
			print(window.name + " set as current_window. in_windows size: ", in_windows.size())
	else:
		in_windows.erase(window)
		print(window.name + " removed from in_windows. Size: ", in_windows.size())

func on_mouse_entered() ->void:
	mouse_hover = true
func on_mouse_exited() ->void:
	mouse_hover = false


func _on_window_grabbed(window:WindowPanel) ->void:
	if get_current_window() != window:
		return
	elif in_windows.has(window):
		set_current_window(window)
	frozen = true
	ball_area.monitoring = false
	ball_area.monitorable = false
func _on_window_released(window:WindowPanel) ->void:
	if get_current_window() != window:
		return
	frozen = false
	ball_area.monitoring = true
	ball_area.monitorable = true


func _on_goal() ->void:
	print("Ball hit goal!")
	current_speed = 0.0
	velocity = Vector2.ZERO
	move_dir = Vector2.ZERO
	anim.play("goal")
	
	await anim.animation_finished
	hide()

func _on_stage_reset() ->void:
	print("Ball reset.")
	frozen = false
	launched = false
	current_speed = 0.0
	current_window = null
	in_windows.clear()
	velocity = Vector2.ZERO
	move_dir = Vector2.ZERO
	global_position = start_position.global_position
