extends Button

const DISABLED_THEME_VARIATION := &"DisabledLabel"

@onready var button_label: Label = $ButtonLabel
@onready var selected_texture: NinePatchRect = $SelectedTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_label.text = text
	text = ""
	selected_texture.hide()
	
	if disabled:
		button_label.theme_type_variation = DISABLED_THEME_VARIATION

func hover_enter() ->void:
	selected_texture.show()

func hover_exit() ->void:
	selected_texture.hide()
