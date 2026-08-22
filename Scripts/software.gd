extends Control

const ENTER_TIME := 0.4
const EXIT_TIME := 0.4

@onready var panel_parent: PanelContainer = %PanelParent
@onready var content: Control = %Content


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func enter() ->void:
	show()
	panel_parent.show()
	panel_parent.scale = Vector2.ZERO
	
	var enter_tween := get_tree().create_tween()
	enter_tween.tween_property(panel_parent, "scale", Vector2.ONE, ENTER_TIME)
	
	await enter_tween.finished
	content.show()
	print(name, " Entered - visible:", visible)
