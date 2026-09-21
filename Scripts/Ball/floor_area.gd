class_name FloorArea extends Area2D

var in_windows : Array[WindowPanel]
var in_obstacle := false
var outside_window := false

@onready var ball: Ball = $".."
@onready var collider: CollisionShape2D = $FloorAreaCollider

signal new_current_window(window:WindowPanel)
signal goal_entered
signal fell_out
signal stuck

signal valid_spot
signal invalid_spot

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func set_area_enabled(enabled:bool) ->void:
	#print("!!!Floor area enabled: ", enabled)
	collider.set_deferred("disabled", !enabled)

func recheck_current_window() ->WindowPanel:
	in_windows.clear()
	
	var areas := get_overlapping_areas()
	for area in areas:
		if area is MoveArea:
			in_windows.append(area.window_parent)
	
	var valid_idx := check_valid_window()
	if valid_idx < 0:
		printerr("fuck")
		return null
	
	return in_windows.pop_at(valid_idx)

func add_to_window_list(window:WindowPanel) ->void:
	if window == ball.get_current_window() or in_windows.has(window):
		return
	
	in_windows.append(window)
	#print(window.name + " added to in_windows. Size: ", in_windows.size())

func check_valid_window() ->int:
	var valid := -1
	
	if in_windows.size() == 0:
		return valid
	
	for i : int in in_windows.size():
		var window := in_windows[i]
		print(window.name, window.z_index)
		if valid < 0:
			if window.z_index < ball.z_index:
				valid = i
		else:
			if window.z_index > in_windows[valid].z_index and window.z_index < ball.z_index:
				valid = i
	
	return valid

func check_valid_launch_spot() ->void:
	if get_overlapping_areas().size() == 0:
		invalid_spot.emit()
		return
	elif get_overlapping_bodies().size() > 0:
		invalid_spot.emit()
		return
	valid_spot.emit()

func update_valid_launch_spot() ->void:
	if in_obstacle or outside_window:
		invalid_spot.emit()
	else:
		valid_spot.emit()


func _on_area_entered(area: Area2D) -> void:
	print("Floor area entered")
	if area is GoalArea:
		goal_entered.emit()
		return
	elif area is not MoveArea:
		return
	
	var move_area := area as MoveArea
	var window := move_area.get_window_panel()
	
	if !ball.get_current_window():
		print("--hoohoo")
		outside_window = false
		update_valid_launch_spot()
		new_current_window.emit(window)
	else:
		add_to_window_list(window)
	#print(" -- AreaEntered -- ", window.name, ", CurrentWindow: ", current_window,", in_windows: ", in_windows, "\n")

func _on_area_exited(area: Area2D) -> void:
	if collider.disabled: # Problematic ?
		return
	elif area is not MoveArea:
		return
	
	var move_area := area as MoveArea
	var window := move_area.get_window_panel()
	print("Ball exited " + window.name + ".")
	
	if window == ball.get_current_window():
		print("Exiting current window!!!")
		var valid_index := check_valid_window()
		if valid_index < 0:
			outside_window = true
			if !ball.launched:
				update_valid_launch_spot()
				new_current_window.emit(null)
			else:
				fell_out.emit()
		else:
			var valid_window = in_windows.pop_at(valid_index)
			new_current_window.emit(valid_window)
			print(valid_window.name + " set as current_window. in_windows size: ", in_windows.size())
	else:
		in_windows.erase(window)
		print(window.name + " removed from in_windows. Size: ", in_windows.size())

# Check for collision
func _on_body_entered(body: Node2D) -> void:
	in_obstacle = true
	print("body entered: ", body.name, " - in_obstacle: ", in_obstacle)
	
	if ball.launched:
		stuck.emit()
	else:
		update_valid_launch_spot()

func _on_body_exited(body: Node2D) -> void:
	in_obstacle = get_overlapping_bodies().size() > 0
	print("body exited: ", body.name, " - in_obstacle: ", in_obstacle)
	
	if !ball.launched:
		update_valid_launch_spot()
