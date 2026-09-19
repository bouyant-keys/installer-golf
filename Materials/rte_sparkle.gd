@tool
class_name SparkleTextEffect extends RichTextEffect

## Syntax: [sparkle weight={float} color={color_name/hex_code}]{text}[/sparkle]
var bbcode = "sparkle"

func _process_custom_fx(c: CharFXTransform) -> bool:
	var color : Color = c.env.get("color", Color(1.0, 1.0, 1.0, 1.0))
	var weight : float = c.env.get("weight", 2.0)
	c.color = color
	
	var s = 1.0 - color.s
	var speed := c.elapsed_time * 12.0
	c.color.h = wrapf(color.h + sin(-speed + c.relative_index * 2.0) * s * .033 * weight, 0.0, 1.0)
	c.color.v = clamp(color.v + sin(speed + c.relative_index) * .25 * weight, 0.0, 1.0)
	return true
