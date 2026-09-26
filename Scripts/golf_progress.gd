extends Control

const TEXT_FORMAT := "Preparing Installation......%3.1f%%"
const UPDATING_TEXT_FORMAT := "Preparing Installation......[color=blue]%3.1f%%[/color]"
const TWEEN_TIME := 2.0

@export var stage_manager : StageManager

@onready var progress_window: WindowPanel = %ProgressWindow
@onready var progress_text: CustomRichText = $ProgressWindow/MarginContainer/ProgressText
@onready var golf_progress: TextureProgressBar = %GolfProgress

func _ready() -> void:
	stage_manager.game_start.connect(_on_game_start)
	stage_manager.game_end.connect(_on_game_end)
	stage_manager.stage_changed.connect(_on_stage_changed)
	#stage_manager.ball_stopped.connect(highlight_retry)
	
	golf_progress.value = 0.0

#func highlight_retry() ->void:
	#pass

func _on_game_start() ->void:
	progress_window.enter()

func _on_game_end() ->void:
	progress_window.exit()

func _on_stage_changed(index:int) ->void:
	var progress_ratio := 0.0 if index == 0 else (index + 1) / float(stage_manager.stages.size())
	
	var progress_tween := get_tree().create_tween()
	progress_tween.tween_method(tween_golf_progress, golf_progress.value, progress_ratio * 100.0, TWEEN_TIME).set_ease(Tween.EASE_IN_OUT)
	
	await progress_tween.finished
	progress_text.text = TEXT_FORMAT % golf_progress.value

func tween_golf_progress(value:float) ->void:
	golf_progress.value = value
	progress_text.text = UPDATING_TEXT_FORMAT % value
