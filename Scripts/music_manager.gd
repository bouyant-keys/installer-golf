extends AudioStreamPlayer

@export var loop_music : AudioStream
@export var end_music : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_loop_music() ->void:
	stream = loop_music
	play()

func play_end_music() ->void:
	stream = end_music
	play()

func stop_music() ->void:
	stop()
