class_name GoalArea extends Area2D

const DOWNLOAD_TIME := 1.5

signal goal

@onready var download_bar: ProgressBar = %DownloadBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	download_bar.value = 0.0

func on_area_entered(_area:Area2D) ->void:
	print("Winnar!")
	var download_tween := get_tree().create_tween()
	download_tween.tween_property(download_bar, "value", 100.0, DOWNLOAD_TIME)
	
	await download_tween.finished
	goal.emit()
