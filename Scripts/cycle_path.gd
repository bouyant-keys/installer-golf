extends Path2D

@export var move := true
@export var speed := 2.0
@export var follower : Control

@onready var path_follow: PathFollow2D = $PathFollow2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_physics_process(move)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	path_follow.progress_ratio += speed * delta
	follower.global_position = path_follow.global_position
