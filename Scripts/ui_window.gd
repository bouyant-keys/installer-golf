class_name UIWindow extends Control

const ENTER_TIME := 0.4
const EXIT_TIME := 0.4

var start_position : Vector2
var move_start : Vector2
var drag_start : Vector2
var is_draggable := true
var grabbed := false

@export var title_text : String
@export var is_locked := false

@onready var panel_parent: PanelContainer = %PanelParent
@onready var window_title: Label = %WindowTitle

signal window_entered
signal window_exited

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if title_text.is_empty():
		window_title.text = name
	else:
		window_title.text = title_text
	
	set_children_visibility(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = move_start + (get_global_mouse_position() - drag_start)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("LeftClick"):
		#select()
		
		if !grabbed:
			return
		
		if is_locked:
			##TODO Visual cue that window is locked in place...
			#anim.play("locked")
			return
		drag_start = get_global_mouse_position()
		move_start = global_position
		#window_grabbed.emit(self)
		set_process(true)
	elif event.is_action_released("LeftClick"):
		#window_released.emit(self)
		set_process(false)

func enter() ->void:
	show()
	panel_parent.show()
	panel_parent.scale = Vector2.ZERO
	
	var enter_tween := get_tree().create_tween()
	enter_tween.tween_property(panel_parent, "scale", Vector2.ONE, ENTER_TIME)
	
	await enter_tween.finished
	window_entered.emit()
	set_children_visibility(true)
	print(name, " Entered - visible:", visible)

func exit() ->void:
	set_children_visibility(false)
	panel_parent.show()
	panel_parent.scale = Vector2.ONE
	
	var exit_tween := get_tree().create_tween()
	exit_tween.tween_property(panel_parent, "scale", Vector2.ZERO, EXIT_TIME)
	
	await exit_tween.finished
	window_exited.emit()
	hide()

func set_children_visibility(active:bool) ->void:
	for child : Node in get_children():
		if child is StaticObstacle:
			continue
		elif child is Node2D:
			child.visible = active
		elif child is Control:
			child.visible = active
