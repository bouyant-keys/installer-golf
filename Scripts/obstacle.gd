extends AnimatableBody2D

@export var follow : Control
@export var follow_offset : Vector2
## Set collider size to the bounding rect of the follow control.
@export var collider_fit_rect := false

@onready var collider: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !collider_fit_rect:
		return
	
	var col_shape := RectangleShape2D.new()
	col_shape.size = follow.get_rect().size
	collider.shape = col_shape


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	global_position = (follow.global_position + follow_offset) + collider.shape.get_rect().size / 2.0
