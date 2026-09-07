extends Control

const TEXT_FORMAT := "Preparing Installation......%3.1f%%"

@export var stage_manager : StageManager

@onready var progress_window: WindowPanel = %ProgressWindow
@onready var progress_text: CustomRichText = $ProgressWindow/MarginContainer/ProgressText
@onready var golf_progress: TextureProgressBar = %GolfProgress

func _ready() -> void:
	stage_manager.game_start.connect(_on_game_start)
	stage_manager.game_end.connect(_on_game_end)
	stage_manager.stage_changed.connect(_on_stage_changed)
	
	golf_progress.value = 0.0
	golf_progress.max_value = stage_manager.stages.size()-1

func _on_game_start() ->void:
	progress_window.enter()

func _on_game_end() ->void:
	progress_window.exit()

func _on_stage_changed(index:int) ->void:
	var progress_ratio := (index + 1) / float(stage_manager.stages.size())
	print(index, " - ", stage_manager.stages.size(), " - ", progress_ratio)
	progress_text.text = TEXT_FORMAT % (progress_ratio * 100.0) 
	golf_progress.value = index
