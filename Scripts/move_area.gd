class_name MoveArea extends Area2D

@export var window_parent : WindowPanel
@export var move_panel : PanelContainer

@onready var move_collider: CollisionShape2D = %MoveCollider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	window_parent.entered.connect(fit_collider)

func get_window_panel() ->WindowPanel:
	return window_parent

func get_movable_area() ->Rect2:
	var move_rect := move_collider.shape.get_rect()
	move_rect.position += move_collider.global_position
	return move_rect

func get_collider_position() ->Vector2:
	return move_collider.shape.get_rect().position + move_collider.global_position

func fit_collider() ->void:
	move_collider.global_position = move_panel.global_position + (move_panel.size / 2.0)
	
	#var collision_shape := RectangleShape2D.new()
	#collision_shape.size = move_panel.size
	#move_collider.shape = collision_shape
	move_collider.shape.size = move_panel.size
	print("..FitCollider: ", move_collider.shape.size)
