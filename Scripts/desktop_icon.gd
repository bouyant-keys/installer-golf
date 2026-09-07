extends TextureButton

@export var icon_text : String = "File.txt"

@onready var label: Label = $Label
@onready var selected_texture: Panel = $SelectedTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = icon_text
	selected_texture.hide()
