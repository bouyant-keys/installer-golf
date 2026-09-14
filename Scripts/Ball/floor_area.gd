class_name FloorArea extends Area2D

var in_windows : Array[WindowPanel]

@onready var ball: Ball = $".."
@onready var collider: CollisionShape2D = $FloorAreaCollider

signal new_current_window(window:WindowPanel)
signal goal_entered
signal fell_out

#func _ready() -> void:
	#set_area_enabled(false)

func set_area_enabled(enabled:bool) ->void:
	#print("!!!Floor area enabled: ", enabled)
	collider.set_deferred("disabled", !enabled)

func recheck_area() ->void:
	#TODO Implement!
	pass

func add_to_window_list(window:WindowPanel) ->void:
	if window == ball.get_current_window() or in_windows.has(window):
		return
	
	in_windows.append(window)
	#print(window.name + " added to in_windows. Size: ", in_windows.size())

func check_valid_window() ->WindowPanel:
	var enter_window : WindowPanel = null
	# stupid way to access the window_manager but idrc
	var overlap_windows := ball.window_manager.get_windows_at_position(global_position)
	for window : WindowPanel in overlap_windows:
		if !enter_window:
			if window.z_index < z_index:
				enter_window = window
		else:
			if window.z_index > enter_window.z_index and window.z_index < z_index:
				enter_window = window
	
	return enter_window


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
		var valid_window := check_valid_window()
		if !valid_window:
			fell_out.emit()
			#fell_out = true
			return
		else:
			new_current_window.emit(valid_window)
			#in_windows.remove_at(0)
			print(window.name + " set as current_window. in_windows size: ", in_windows.size())
	else:
		in_windows.erase(window)
		print(window.name + " removed from in_windows. Size: ", in_windows.size())
