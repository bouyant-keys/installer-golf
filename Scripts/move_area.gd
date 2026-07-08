class_name MoveArea extends Area2D

@export var window_parent : WindowPanel

@onready var move_panel: PanelContainer = %MovePanel
@onready var move_collider: CollisionShape2D = %MoveCollider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup.call_deferred()
func setup() ->void:
	global_position = move_panel.global_position + (move_panel.size / 2.0)
	
	var collision_shape := RectangleShape2D.new()
	collision_shape.size = move_panel.size
	move_collider.shape = collision_shape
	print("MoveArea Collider Size: ", collision_shape.size)

func get_window_panel() ->WindowPanel:
	return window_parent

func get_movable_area() ->Rect2:
	var collider_rect := move_collider.shape.get_rect()
	# Position is set to top-left corner of collider shape
	collider_rect.position += move_collider.global_position
	#print("MovableArea: ", collider_rect)
	return collider_rect
