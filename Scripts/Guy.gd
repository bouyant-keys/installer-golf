extends Control

const MOVE_SPEED := 200.0
const DECEL_RATE := 15.0
const EDGE_MARGIN := 2.0
const STRENGTH_RANGE := Vector2(10.0, 200.0)
const DRAG_MAX := 160.0 # Furthest distance in pixels to drag for a shot, means the maximum strength is applied

var move_dir := Vector2.ZERO
var local_position : Vector2
var current_speed : float = MOVE_SPEED
var current_window : WindowPanel
var in_windows : Array[WindowPanel]
var bounce_margin : float
var mouse_hover := false
var mouse_drag := false
var click_pos : Vector2

#@export var randomize_start_direction := false
#@export var initial_direction := Vector2(1.0, -0.75)
@export var start_position : Control
@export var window_manager : WindowManager

@onready var ball_area: Area2D = $BallArea
@onready var trajectory: Line2D = $Trajectory

signal trajectory_changed(trajectory:Vector2, strength:float)
signal draw_trajectory(enabled:bool)
signal direction_changed(at_pos:Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = start_position.global_position

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("LeftClick") && mouse_hover:
		print("Clicked")
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
		draw_trajectory.emit(false)
		#print("Released, Pos: ", release_pos, ", Distance: ", release_pos - click_pos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mouse_drag:
		var launch_dir := -(get_global_mouse_position() - click_pos)
		var launch_strength := clampf(launch_dir.length(), STRENGTH_RANGE.x, STRENGTH_RANGE.y)
		trajectory_changed.emit(launch_dir, launch_strength)
		print("Launch Strength: ", launch_strength)
		return
	elif move_dir.is_equal_approx(Vector2.ZERO):
		print("No Direction!")
		return
	
	if !check_in_movable_areas():
		print("Ball not in an area! ", global_position)
		return
	
	var current_movable_area := current_window.get_movable_area()
	
	# Calculate character's next position from their speed & direction
	current_speed = move_toward(current_speed, 0.0, DECEL_RATE * delta)
	var next_pos := local_position + (move_dir * current_speed * delta)
	
	# Check whether the next position is within an intersection of multiple windows (ignoring bounds[0]):
	var in_intersection : bool
	if in_windows.size() == 0:
		# if character is only in current_window, there's no chance of being in an intersecting area
		in_intersection = false
	else:
		var global_next_pos := next_pos + current_movable_area.position
		in_intersection = check_in_window_intersection(global_next_pos)
		print("In_Intersection: ", in_intersection)
	
	# Restrain character inside bounds based on min & max pos,
	# otherwise use the previous local window position by default.
	var clamp_pos := local_position
	if !in_intersection:
		# If not in an intersection: enforce bounaries, update move_dir, & update clamp position
		# otherwise: ignore bounds and allow character to pass (don't change move_dir or clamp next_pos).
		var min_pos := Vector2(EDGE_MARGIN, EDGE_MARGIN)
		var max_pos := current_movable_area.size - (size + Vector2(EDGE_MARGIN, EDGE_MARGIN))
		#print("Min_pos: ", min_pos, ", Max_pos: ", max_pos)
		if local_position.x <= min_pos.x:
			print("Out of bounds: Min X ", min_pos.x)
			move_dir = move_dir.bounce(Vector2.RIGHT)
			clamp_pos.x = min_pos.x
		elif local_position.x >= max_pos.x:
			print("Out of bounds: Max X ", max_pos.x)
			move_dir = move_dir.bounce(Vector2.RIGHT)
			clamp_pos.x = max_pos.x
		
		if local_position.y <= min_pos.y:
			print("Out of bounds: Min Y ", min_pos.y)
			move_dir = move_dir.bounce(Vector2.UP)
			clamp_pos.y = min_pos.y
		elif local_position.y >= max_pos.y:
			print("Out of bounds: Max Y ", max_pos.y)
			move_dir = move_dir.bounce(Vector2.UP)
			clamp_pos.y = max_pos.y
	
	if !clamp_pos.is_equal_approx(local_position):
		print("Bounced!")
		direction_changed.emit(global_position)
	
	#print("Global: ", global_position, ", Clamp: ", clamp_pos, ", Move_dir: ", move_dir)
	# Update next_pos with potentially changed values, & assign to global position.
	local_position = clamp_pos + (move_dir * current_speed * delta)
	global_position = local_position + current_movable_area.position

func check_in_movable_areas() ->bool:
	var in_movable_area := false
	
	var movable_areas : Array[MoveArea]
	for area in ball_area.get_overlapping_areas():
		if area is MoveArea:
			movable_areas.append(area as MoveArea)
	
	in_movable_area = movable_areas.size() > 0
	
	if in_movable_area && !current_window:
		print(movable_areas[0].get_parent().name)
		set_current_window(movable_areas[0].get_window_panel())
	
	return in_movable_area

## Returns true if [param pos] is within the shape of any one of the Rect2s in [param bounds].
func check_in_window_intersection(pos:Vector2) ->bool:
	var overlap_pos := false
	for i : int in in_windows.size():
		if in_windows[i].get_rect().has_point(pos):
			overlap_pos = true
			print("Overlapping with: ", in_windows[i].name)
			break
	return overlap_pos

func set_current_window(window:WindowPanel) ->void:
	current_window = window
	local_position = global_position - current_window.get_in_movable_area().position

## Returns a normalized Vector2 with a random (positive or negative) orientation.
func get_random_direction() ->Vector2:
	var rand_rot : float = randf_range(0.0, TAU)
	return Vector2.ONE.rotated(rand_rot).normalized()

func _on_collision_area_entered(area: Area2D) ->void:
	pass

func _on_ball_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	print(parent.name, " entered.")
	if parent is not WindowPanel:
		return
	
	if !current_window:
		set_current_window(parent)
		set_process(true)
	else:
		in_windows.append(parent)

func _on_ball_area_exited(area: Area2D) -> void:
	var parent := area.get_parent()
	print(parent.name, " exited.")
	if parent is not WindowPanel:
		return
	
	if parent == current_window:
		if in_windows.size() == 0:
			printerr("Character out of bounds!")
			return
		else:
			set_current_window(in_windows[0])
			in_windows.remove_at(0)
	else:
		in_windows.erase(parent)

func on_mouse_entered() ->void:
	mouse_hover = true
	print("Mouse Entered ball!!!11!")
func on_mouse_exited() ->void:
	mouse_hover = false

func _on_goal() ->void:
	current_speed = 0.0
	move_dir = Vector2.ZERO

func _reset() ->void:
	global_position = start_position.global_position
