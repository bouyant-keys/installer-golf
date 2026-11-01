class_name WindowManager extends Control

const WIN_ENTER_TIME := 0.2
const START_Z := -200
const ERROR_Z := -100
const Z_OFFSET := 2

@export var start_selected_window : WindowPanel

var stage : Stage
var windows_have_entered := false
var ball_window : WindowPanel
var windows : Array[WindowPanel]
var selected_window : WindowPanel
var selected_index : int

signal windows_entered
signal windows_exited
signal new_current_window(window:WindowPanel)
signal child_window_selected(window:WindowPanel)
signal child_window_grabbed(window:WindowPanel)
signal child_window_released(window:WindowPanel)

signal child_window_resize_start(window:ResizableWindow)
signal child_window_resized(window:ResizableWindow)
signal child_window_resize_end(window:ResizableWindow)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stage = get_parent() as Stage
	stage.enter_windows.connect(_enter_windows)
	stage.exit_windows.connect(_exit_windows)
	
	for child : Control in get_children():
		if child is WindowPanel:
			child.window_selected.connect(_on_window_selected)
			child.window_grabbed.connect(_on_window_grabbed)
			child.window_released.connect(_on_window_released)
			new_current_window.connect(child._on_new_current_window)
			if child is ResizableWindow:
				child.window_resize_start.connect(_on_window_resize_start)
				child.window_resized.connect(_on_window_resized)
				child.window_resize_end.connect(_on_window_resize_end)
			windows.append(child)
	
	for i : int in windows.size():
		var window := windows[i]
		if window.is_error:
			window.z_index = ERROR_Z + (i * Z_OFFSET)
		else:
			window.z_index = START_Z + (i * Z_OFFSET)
	
	# Set the selected window at the end of the _ready frame.
	if start_selected_window:
		start_selected_window.select.call_deferred()

func _enter_windows() ->void:
	for window in windows:
		if window.enter_on_start: window.enter()
		await get_tree().create_timer(WIN_ENTER_TIME).timeout
	await windows[-1].entered
	windows_have_entered = true
	windows_entered.emit()

func _exit_windows() ->void:
	for window in windows:
		window.exit()
		await get_tree().create_timer(WIN_ENTER_TIME).timeout
	windows_exited.emit()

func get_windows_at_position(at:Vector2) ->Array[WindowPanel]:
	var wins : Array[WindowPanel]
	for window in windows:
		var move_rect := window.get_movable_area()
		if move_rect.has_point(at):
			wins.append(window)
	return wins


# Use array where index indicates z_index - higher position = upper z leyer/index
# When a window is selected, move it to the end / highest point of the list & update z_indices for windows list.
func set_top_window(w:WindowPanel) ->void:
	if !windows_have_entered:
		return
	
	# Move selected window to back of array, then remove previous instance (earlier in the array)
	windows.append(w)
	windows.erase(w) # removes first instance which should be the old one
	
	for i : int in windows.size():
		var window := windows[i]
		if window.is_error:
			window.z_index = ERROR_Z + (i * Z_OFFSET)
		else:
			window.z_index = START_Z + (i * Z_OFFSET)
		window.is_selected = false


func _on_current_window_changed(c_window:WindowPanel) ->void:
	ball_window = c_window
	new_current_window.emit(ball_window)
	set_top_window(c_window)

func _on_window_selected(s_window:WindowPanel) ->void:
	s_window.is_selected = true
	selected_window = s_window
	child_window_selected.emit(s_window)

func _on_window_grabbed(window:WindowPanel) ->void:
	child_window_grabbed.emit(window)
func _on_window_released(window:WindowPanel) ->void:
	child_window_released.emit(window)
func _on_window_resize_start(window:ResizableWindow) ->void:
	child_window_resize_start.emit(window)
func _on_window_resized(window:ResizableWindow) ->void:
	child_window_resized.emit(window)
func _on_window_resize_end(window:ResizableWindow) ->void:
	child_window_resize_end.emit(window)

func _on_stage_reset() ->void:
	for window in windows:
		window._reset()
