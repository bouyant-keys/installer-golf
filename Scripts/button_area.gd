extends Area2D

@export var button_text := ""
@export var pressed := false

@onready var button: Button = $Button
@onready var collider: CollisionShape2D = $CollisionShape2D

signal button_toggled(on:bool)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var button_rect := button.get_rect()
	collider.global_position = collider.global_position + button_rect.size / 2.0
	var shape := RectangleShape2D.new()
	shape.size = button_rect.size
	collider.shape = shape
	
	button.text = button_text

func on_body_entered(body:Node2D) ->void:
	if body is Ball:
		pressed = !pressed
		button_toggled.emit(pressed)
		update_display()
func on_body_exited(body:Node2D) ->void:
	if body is Ball:
		button.button_pressed = false

func update_display() ->void:
	button.button_pressed = pressed

func get_button_state() ->bool:
	return pressed
