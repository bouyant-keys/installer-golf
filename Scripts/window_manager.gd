class_name WindowManager extends Control

const WINDOW_GRADIENT : GradientTexture1D = preload("uid://bicpm8unswqyx")
const SELECTED_WINDOW_Z := 0
const DEFAULT_WINDOW_Z := -10

var windows : Array[WindowPanel]
var selected_window : WindowPanel
var selected_index : int

signal window_selected(window:WindowPanel)
signal window_grabbed(window:WindowPanel)
signal window_released(window:WindowPanel)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		var window := child as WindowPanel
		window.window_selected.connect(_on_window_selected)
		window.window_grabbed.connect(_on_window_grabbed)
		window.window_released.connect(_on_window_released)
		windows.append(window)
	
	for i : int in windows.size():
		var window := windows[i]
		window.z_index = i
		var gradient_sample := 1.0 - (i / float(windows.size()))
		print("Index: ", i, ", SampleValue: ", gradient_sample)
		window.modulate = WINDOW_GRADIENT.gradient.sample(gradient_sample)

func get_windows_at_position(at:Vector2) ->Array[WindowPanel]:
	var wins : Array[WindowPanel]
	for window in windows:
		var move_rect := window.get_movable_area()
		print("- MoveAreaRect: ", move_rect, ", AtPos: ", at, ", HasPoint: ", move_rect.has_point(at))
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
		window.z_index = i
		window.is_selected = false
		
		var gradient_sample := 1.0 - (i / float(windows.size()))
		window.modulate = WINDOW_GRADIENT.gradient.sample(gradient_sample)
		
		if window == s_window:
			window.is_selected = true
			selected_window = window
			continue
	
	window_selected.emit(s_window)

func _on_window_grabbed(window:WindowPanel) ->void:
	window_grabbed.emit(window)
func _on_window_released(window:WindowPanel) ->void:
	window_released.emit(window)

func _on_stage_reset() ->void:
	for window in windows:
		window._reset()
