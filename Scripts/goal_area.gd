class_name GoalArea extends Area2D

const FINAL_BUTTON_TEXT : String = "Install"

var relative_position : Vector2

@export var parent_window : WindowPanel
@export var is_intro_level := false
@export var is_final_level := false
@export var tab_id := -1

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var mouse_press_sfx: AudioStreamPlayer = $MousePressSFX
@onready var goal_sfx: AudioStreamPlayer = $GoalSFX
@onready var collider: CollisionShape2D = $CollisionShape2D

signal goal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	relative_position = global_position
	
	if !parent_window:
		var parent := get_parent()
		if parent is WindowPanel:
			parent_window = parent
	
	parent_window.reordered.connect(_on_window_reordered)
	parent_window.window_released.connect(_on_window_released)
	parent_window.resized.connect(_on_window_resized)
	
	if parent_window is TabWindow:
		parent_window.window_tab_changed.connect(_on_window_tab_changed)
	
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

func _on_window_tab_changed(index:int) ->void:
	collider.set_deferred("disabled", index != tab_id)

func _on_window_reordered(z:int) ->void:
	z_index = z

func _on_window_released(_window:WindowPanel) ->void:
	relative_position = global_position
	print(name + " relative pos set: ", relative_position)

# Don't move goal area if parent window's position changes when resized.
func _on_window_resized() ->void:
	global_position = relative_position
