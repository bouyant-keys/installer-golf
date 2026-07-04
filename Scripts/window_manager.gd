class_name WindowManager extends Control

const SELECTED_WINDOW_Z := 5
const DEFAULT_WINDOW_Z := -1

@export var stage : Stage

var windows : Array[WindowPanel]
var selected_window : WindowPanel
var selected_index : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stage.reset.connect(_on_stage_reset)
	
	for child in get_children():
		var window := child as WindowPanel
		
		window.window_selected.connect(on_window_selected)
		windows.append(window)

func on_window_selected(s_window:WindowPanel) ->void:
	for window in windows:
		if window == s_window:
			selected_window = window
			window.z_index = SELECTED_WINDOW_Z
			continue
			
		window.z_index = DEFAULT_WINDOW_Z

func _on_stage_reset() ->void:
	for window in windows:
		window._reset()
