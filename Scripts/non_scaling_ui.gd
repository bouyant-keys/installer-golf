extends Control

var relative_position : Vector2
@export var parent_window : WindowPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	relative_position = global_position
	
	if !parent_window:
		var parent := get_parent()
		if parent is WindowPanel:
			parent_window = parent
	
	parent_window.window_released.connect(_on_window_released)
	parent_window.resized.connect(_on_window_resized)

func _on_window_released(_window:WindowPanel) ->void:
	relative_position = global_position
	print("Relative pos set: ", relative_position)#, ", from: ", window)

func _on_window_resized() ->void:
	global_position = relative_position
