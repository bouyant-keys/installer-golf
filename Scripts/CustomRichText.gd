@tool
class_name CustomRichText extends RichTextLabel

const ENTER_TIME := 1.0
const EXIT_TIME := 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	install_effect(SineTextEffect.new()) # Installs Sine effect
	install_effect(SparkleTextEffect.new()) # Installs Sparkle effect
	install_effect(ReplaceTextEffect.new()) # Installs Sparkle effect
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func enter_text() ->void:
	visible_ratio = 0.0
	var enter_tween := get_tree().create_tween()
	enter_tween.tween_property(self, "visible_ratio", 1.0, ENTER_TIME)

func exit_text() ->void:
	visible_ratio = 1.0
	var exit_tween := get_tree().create_tween()
	exit_tween.tween_property(self, "visible_ratio", 0.0, EXIT_TIME)
