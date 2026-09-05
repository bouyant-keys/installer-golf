extends Control

var start_position : Vector2
@export var parent_window : WindowPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = global_position
	
	if !parent_window:
		var parent := get_parent()
		if parent is WindowPanel:
			parent_window = parent
	parent_window.resized.connect(_on_window_resized)

func _on_window_resized() ->void:
	global_position = start_position
