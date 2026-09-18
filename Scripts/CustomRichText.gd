@tool
class_name CustomRichText extends RichTextLabel

const ENTER_TIME := 1.0
const EXIT_TIME := 1.0
const OBSTACLE_FORMAT := "[cuss]%s[/cuss]"

@export var is_text_obstacle := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !custom_effects.has(SineTextEffect):
		install_effect(SineTextEffect.new()) # Installs Sine effect
	if !custom_effects.has(SparkleTextEffect):
		install_effect(SparkleTextEffect.new()) # Installs Sparkle effect
	if !custom_effects.has(ReplaceTextEffect):
		install_effect(ReplaceTextEffect.new()) # Installs Sparkle effect
	bbcode_enabled = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if is_text_obstacle:
		text = OBSTACLE_FORMAT % text

func enter_text() ->void:
	visible_ratio = 0.0
	var enter_tween := get_tree().create_tween()
	enter_tween.tween_property(self, "visible_ratio", 1.0, ENTER_TIME)

func exit_text() ->void:
	visible_ratio = 1.0
	var exit_tween := get_tree().create_tween()
	exit_tween.tween_property(self, "visible_ratio", 0.0, EXIT_TIME)
