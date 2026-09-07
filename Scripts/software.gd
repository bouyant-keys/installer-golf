extends Node

@onready var window: WindowPanel = $Window

signal replay
signal quit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func enter() ->void:
	window.enter()

func _on_replay_button_pressed() -> void:
	replay.emit()

func _on_quit_button_pressed() -> void:
	quit.emit()
