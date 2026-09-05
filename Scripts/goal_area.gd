class_name GoalArea extends Area2D

const FINAL_BUTTON_TEXT : String = "Install"

var start_position : Vector2

@export var parent_window : WindowPanel
@export var is_intro_level := false
@export var is_final_level := false

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var mouse_press_sfx: AudioStreamPlayer = $MousePressSFX
@onready var goal_sfx: AudioStreamPlayer = $GoalSFX

signal goal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = global_position
	
	if !parent_window:
		var parent := get_parent()
		if parent is WindowPanel:
			parent_window = parent
	
	parent_window.reordered.connect(_on_window_reordered)
	parent_window.resized.connect(_on_window_resized)
	hide()
	
	if !is_intro_level:
		enter()

func enter() ->void:
	show()
	anim.play("enter")

func _on_body_entered(body: Node2D) -> void:
	if body is not Ball:
		return
	
	body = body as Ball
	body._on_goal()
	
	anim.play("goal")
	goal_sfx.play()
	
	goal.emit()

func _on_window_reordered(z:int) ->void:
	z_index = z

# Don't move goal area if parent window's position changes when resized.
func _on_window_resized() ->void:
	global_position = start_position
