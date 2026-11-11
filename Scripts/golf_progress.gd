extends Control

const TEXT_FORMAT := "Preparing Installation......%3.1f%%"
const UPDATING_TEXT_FORMAT := "Preparing Installation......[color=blue]%3.1f%%[/color]"
const BOUNCE_HEIGHT := Vector2(0.0, -8.0)
const TWEEN_TIME := 2.0
const BOUNCE_TIME := 0.8
const COMPLETE_HOLD_TIME := 0.2

@export var stage_manager : StageManager

@onready var progress_window: WindowPanel = %ProgressWindow
@onready var progress_text: CustomRichText = $ProgressWindow/MarginContainer/ProgressText
@onready var golf_progress: TextureProgressBar = %GolfProgress
@onready var progress_complete_sfx: AudioStreamPlayer = $ProgressCompleteSFX

signal progress_full

func _ready() -> void:
	stage_manager.game_start.connect(_on_game_start)
	stage_manager.game_end.connect(_on_game_end)
	stage_manager.stage_changed.connect(_on_stage_changed)
	
	golf_progress.value = 0.0

func _on_game_start() ->void: progress_window.enter()
func _on_game_end() ->void: _on_stage_changed(stage_manager.stages.size()-1)

func _on_stage_changed(index:int) ->void:
	if progress_window.has_exited:
		return
	
	var progress_ratio := 0.0 if index == 0 else index / float(stage_manager.stages.size()-1)
	
	var progress_tween := get_tree().create_tween()
	progress_tween.tween_method(tween_golf_progress, golf_progress.value, progress_ratio * 100.0, TWEEN_TIME).set_ease(Tween.EASE_IN_OUT)
	
	await progress_tween.finished
	progress_text.text = TEXT_FORMAT % golf_progress.value
	
	if golf_progress.value == golf_progress.max_value:
		await progress_complete()

func progress_complete() ->void:
	print("work please !")
	var start_pos := progress_window.global_position
	var bounce_pos := progress_window.global_position + BOUNCE_HEIGHT
	progress_window.global_position = bounce_pos
	progress_complete_sfx.play()
	
	var bounce_tween := get_tree().create_tween()
	bounce_tween.tween_property(progress_window, "global_position", start_pos, BOUNCE_TIME)
	bounce_tween.set_ease(Tween.EASE_IN)
	bounce_tween.set_trans(Tween.TRANS_ELASTIC)
	
	await bounce_tween.finished
	progress_full.emit()
	
	await get_tree().create_timer(COMPLETE_HOLD_TIME).timeout
	progress_window.exit()

func tween_golf_progress(value:float) ->void:
	golf_progress.value = value
	progress_text.text = UPDATING_TEXT_FORMAT % value
