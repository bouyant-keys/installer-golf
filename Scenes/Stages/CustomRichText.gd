@tool
class_name CustomRichText extends RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	install_effect(SineTextEffect.new()) # Installs Sine effect
	install_effect(SparkleTextEffect.new()) # Installs Sparkle effect
