class_name MoveArea extends Area2D

@export var window_parent : WindowPanel

@onready var move_collider: CollisionShape2D = %MoveCollider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func get_window_panel() ->WindowPanel:
	return window_parent

func get_movable_area() ->Rect2:
	var collider_rect := move_collider.shape.get_rect()
	# Position is set to top-left corner of collider shape
	collider_rect.position += move_collider.global_position
	return collider_rect
