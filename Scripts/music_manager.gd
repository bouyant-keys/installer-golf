extends AudioStreamPlayer

const VOL_TWEEN_TIME := 1.0

@export var stage_manager: StageManager

@export var start_music : AudioStream
@export var loop_music : AudioStream
@export var end_music : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stage_manager.game_start.connect(play_loop_music)
	stage_manager.game_end.connect(fade_out_music)
	stage_manager.software_start.connect(play_end_music)
	stage_manager.software_end.connect(fade_out_music)
	play_start_music()


func play_start_music() ->void:
	stream = start_music
	play()

func play_loop_music() ->void:
	stream = loop_music
	play()

func play_end_music() ->void:
	stream = end_music
	play()

func fade_out_music() ->void:
	var start_volume := volume_linear
	var volume_tween := get_tree().create_tween()
	volume_tween.tween_property(self, "volume_linear", 0.0, VOL_TWEEN_TIME)
	
	await volume_tween.finished
	stop()
	volume_linear = start_volume


func stop_music() ->void:
	stop()
