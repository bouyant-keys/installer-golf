extends UIButton

@export var stage : Stage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(stage._on_next_pressed)
