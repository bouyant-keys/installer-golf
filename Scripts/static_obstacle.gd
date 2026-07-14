class_name StaticObstacle extends AnimatableBody2D

var local_pos : Vector2
var collider : CollisionShape2D

#@export var follow : Control
#@export var follow_offset : Vector2
### Set collider size to the bounding rect of the follow control.
@export var fit_parent_rect := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	local_pos = position
	collider = get_child(0) as CollisionShape2D
	
	if fit_parent_rect:
		var parent := get_parent() as Control
		var col_shape := RectangleShape2D.new()
		col_shape.size = parent.get_rect().size
		collider.shape = col_shape


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	#global_position = (follow.global_position + follow_offset) + collider.shape.get_rect().size / 2.0
	global_position = get_parent().global_position + local_pos
