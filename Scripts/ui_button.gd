class_name UIButton extends Button

const DISABLED_THEME_VARIATION := &"DisabledLabel"

@onready var button_label: Label = $ButtonLabel
@onready var selected_texture: Control = $SelectedTexture
@onready var hover_sfx: AudioStreamPlayer = $HoverSFX
@onready var pressed_sfx: AudioStreamPlayer = $PressedSFX
@onready var disabled_sfx: AudioStreamPlayer = $"Disabled SFX"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected_texture.hide()
	set_button_text(text)
	set_disabled_state(disabled)

func set_disabled_state(disable:bool) ->void:
	disabled = disable
	button_label.theme_type_variation = DISABLED_THEME_VARIATION if disable else &""

func set_button_text(new_text:String) ->void:
	button_label.text = new_text
	text = ""

func _on_pressed() -> void:
	if disabled:
		disabled_sfx.play()
	else:
		pressed_sfx.play()

func hover_enter() ->void:
	hover_sfx.play()
	selected_texture.visible = !disabled

func hover_exit() ->void:
	selected_texture.hide()
