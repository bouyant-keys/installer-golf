class_name UIWindow extends Control

const ENTER_TIME := 0.4
const EXIT_TIME := 0.4

@export var title_text : String

@onready var panel_parent: PanelContainer = %PanelParent
@onready var window_title: Label = %WindowTitle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if title_text.is_empty():
		window_title.text = name
	else:
		window_title.text = title_text
	
	set_children_visibility(false)

func enter() ->void:
	show()
	panel_parent.show()
	panel_parent.scale = Vector2.ZERO
	
	var enter_tween := get_tree().create_tween()
	enter_tween.tween_property(panel_parent, "scale", Vector2.ONE, ENTER_TIME)
	
	await enter_tween.finished
	set_children_visibility(true)
	print(name, " Entered - visible:", visible)

func exit() ->void:
	set_children_visibility(false)
	panel_parent.show()
	panel_parent.scale = Vector2.ONE
	
	var exit_tween := get_tree().create_tween()
	exit_tween.tween_property(panel_parent, "scale", Vector2.ZERO, EXIT_TIME)
	
	await exit_tween.finished
	hide()

func set_children_visibility(active:bool) ->void:
	for child : Node in get_children():
		if child is StaticObstacle:
			continue
		elif child is Node2D:
			child.visible = active
		elif child is Control:
			child.visible = active
