class_name WindowManager extends Control

const SELECTED_WINDOW_Z := 5
const DEFAULT_WINDOW_Z := -1

var windows : Array[WindowPanel]
var selected_window : WindowPanel
var selected_index : int

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

func _on_window_selected(s_window:WindowPanel) ->void:
	for window in windows:
		if window == s_window:
			window.is_selected = true
			selected_window = window
			window.z_index = SELECTED_WINDOW_Z
			continue
		
		window.is_selected = false
		window.z_index = DEFAULT_WINDOW_Z

func _on_window_grabbed(window:WindowPanel) ->void:
	window_grabbed.emit(window)
func _on_window_released(window:WindowPanel) ->void:
	window_released.emit(window)

func _on_stage_reset() ->void:
	for window in windows:
		window._reset()
