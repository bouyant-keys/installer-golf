extends TextureRect

const BACKGROUND_TEXTURE = preload("uid://daqdhwkosgc7s")
const BACKGROUND_GRADIENT = preload("uid://qnaklbenc2dn")
const COLOR_TWEEN_TIME := 6.0

var bg_texture : GradientTexture2D
var bg_gradient : Gradient
var first_color_lerp : Vector2i
var second_color_lerp : Vector2i
var loop_idx := 0

@export var color_loop : PackedColorArray

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bg_texture = BACKGROUND_TEXTURE.duplicate()
	bg_gradient = BACKGROUND_GRADIENT.duplicate()
	bg_texture.gradient = bg_gradient
	texture = bg_texture
	
	first_color_lerp = Vector2i(loop_idx, posmod(loop_idx+1, color_loop.size()))
	second_color_lerp = Vector2i(posmod(loop_idx+1, color_loop.size()), posmod(loop_idx+2, color_loop.size()))
	print(first_color_lerp, "\n", second_color_lerp)
	tween_color()

func tween_color() ->void:
	var gradient_tween := get_tree().create_tween()
	gradient_tween.tween_method(set_gradient_color, 0.0, 1.0, COLOR_TWEEN_TIME)
	
	await gradient_tween.finished
	loop_idx = posmod(loop_idx+1, color_loop.size())
	first_color_lerp = Vector2i(loop_idx, posmod(loop_idx+1, color_loop.size()))
	second_color_lerp = Vector2i(posmod(loop_idx+1, color_loop.size()), posmod(loop_idx+2, color_loop.size()))
	tween_color()

func set_gradient_color(weight:float) ->void:
	var new_colors : PackedColorArray
	new_colors.append(color_loop[first_color_lerp.x].lerp(color_loop[first_color_lerp.y], weight))
	new_colors.append(color_loop[second_color_lerp.x].lerp(color_loop[second_color_lerp.y], weight))
	#print(new_colors)
	bg_gradient.colors = new_colors
