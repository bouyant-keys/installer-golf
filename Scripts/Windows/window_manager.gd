class_name WindowManager extends Control

const WINDOW_GRADIENT : GradientTexture1D = preload("uid://bwy0fxxdrdp17")#preload("uid://bicpm8unswqyx")
const Z_OFFSET := 10

var stage : Stage
var windows : Array[WindowPanel]
var selected_window : WindowPanel
var selected_index : int

signal windows_entered
signal windows_exited
signal child_window_selected(window:WindowPanel)
signal child_window_grabbed(window:WindowPanel)
signal child_window_released(window:WindowPanel)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stage = get_parent() as Stage
	stage.enter_windows.connect(_enter_windows)
	stage.exit_windows.connect(_exit_windows)
	
	for child in get_children():
		var window := child as WindowPanel
		window.window_selected.connect(_on_window_selected)
		window.window_grabbed.connect(_on_window_grabbed)
		window.window_released.connect(_on_window_released)
		windows.append(window)
	
	for i : int in windows.size():
		var window := windows[i]
		window.z_index = (i * Z_OFFSET)
		window.modulate = get_window_color(i)

func _enter_windows() ->void:
	for window in windows:
		if window.enter_on_start: window.enter()
		await get_tree().create_timer(0.2).timeout
	await windows[-1].entered
	windows_entered.emit()

func _exit_windows() ->void:
	for window in windows:
		window.exit()
		await get_tree().create_timer(0.2).timeout
	windows_exited.emit()

func get_windows_at_position(at:Vector2) ->Array[WindowPanel]:
	var wins : Array[WindowPanel]
	for window in windows:
		var move_rect := window.get_movable_area()
		#print("- MoveAreaRect: ", move_rect, ", AtPos: ", at, ", HasPoint: ", move_rect.has_point(at))
		if move_rect.has_point(at):
			wins.append(window)
	return wins

func _on_current_window_changed(c_window:WindowPanel) ->void:
	for window : WindowPanel in windows:
		if window == c_window:
			window.ball_entered.emit()
		else:
			window.ball_exited.emit()

# Use array where index indicates z_index - higher position = upper z leyer/index
# When a window is selected, move it to the end / highest point of the list & update z_indices for windows list.
func _on_window_selected(s_window:WindowPanel) ->void:
	# Move selected window to back of array, then remove previous instance (earlier in the array)
	windows.append(s_window)
	windows.erase(s_window) # removes first instance which should be the old one
	
	for i : int in windows.size():
		var window := windows[i]
		window.z_index = (i * Z_OFFSET)
		window.is_selected = false
		window.modulate = get_window_color(i)
		
		if window == s_window:
			window.is_selected = true
			selected_window = window
	
	child_window_selected.emit(s_window)

func get_window_color(index:int) ->Color:
	var gradient_sample := index * (1/float(windows.size()-1))
	#print("Index: ", index, ", Sample: ", gradient_sample)
	return WINDOW_GRADIENT.gradient.sample(1.0 - gradient_sample)

func _on_window_grabbed(window:WindowPanel) ->void:
	child_window_grabbed.emit(window)
func _on_window_released(window:WindowPanel) ->void:
	child_window_released.emit(window)

func _on_stage_reset() ->void:
	for window in windows:
		window._reset()
