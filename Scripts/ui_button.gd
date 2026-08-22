class_name UIButton extends Button

const DISABLED_THEME_VARIATION := &"DisabledLabel"

@onready var button_label: Label = $ButtonLabel
@onready var selected_texture: Control = $SelectedTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_label.text = text
	text = ""
	selected_texture.hide()
	set_disabled_state(disabled)

func set_disabled_state(disable:bool) ->void:
	disabled = disable
	button_label.theme_type_variation = DISABLED_THEME_VARIATION if disable else &""

func hover_enter() ->void:
	selected_texture.show()

func hover_exit() ->void:
	selected_texture.hide()
