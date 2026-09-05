extends Control

@export var stage_manager : StageManager

@onready var progress_window: UIWindow = %ProgressWindow
@onready var golf_progress: TextureProgressBar = %GolfProgress

func _ready() -> void:
	stage_manager.stage_changed.connect(_on_stage_changed)
	
	golf_progress.value = 0.0
	golf_progress.max_value = stage_manager.stages.size()-1

func _on_stage_changed(index:int) ->void:
	golf_progress.value = index
