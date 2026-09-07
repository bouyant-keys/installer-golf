class_name ResizableWindow extends WindowPanel

# Resizing code sourced from FinePointCGI:
# https://github.com/finepointcgi/Drag-Rescale-and-Drop-Windows/blob/main/WindowManager.gd

var reset_to_size : Vector2

var start : Vector2
var initialPosition : Vector2
var isResizing : bool
var resizeX : bool
var resizeY : bool
var initialSize : Vector2
@export var GrabThreshold := 20
@export var ResizeThreshold := 6


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	reset_to_size = size
	clip_contents = true

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		var rect = get_global_rect()
		var localMousePos = event.position - get_global_position()
		
		if abs(localMousePos.x - rect.size.x) < ResizeThreshold:
			start.x = event.position.x
			initialSize.x = get_size().x
			resizeX = true
			isResizing = true
		
		if abs(localMousePos.y - rect.size.y) < ResizeThreshold:
			start.y = event.position.y
			initialSize.y = get_size().y
			resizeY = true
			isResizing = true
		
		if localMousePos.x < ResizeThreshold &&  localMousePos.x > -ResizeThreshold:
			start.x = event.position.x
			initialPosition.x = get_global_position().x
			initialSize.x = get_size().x
			isResizing = true
			resizeX = true
		
		if localMousePos.y < ResizeThreshold &&  localMousePos.y > -ResizeThreshold:
			start.y = event.position.y
			initialPosition.y = get_global_position().y
			initialSize.y = get_size().y
			isResizing = true
			resizeY = true
		#print("isResizing:", isResizing, ", resizeX:", resizeX, ", resizeY:", resizeY, 
		#" | initialPosition:", initialPosition, ", initialSize", initialSize)
		
	if Input.is_action_pressed("LeftClick"):
		if !isResizing:
			return
		
		var newWidth := get_size().x
		var newHeight := get_size().y
		
		if resizeX:
			newWidth = initialSize.x - (start.x - event.position.x)
		
		if resizeY:
			newHeight = initialSize.y - (start.y - event.position.y)
		
		if initialPosition.x != 0: # If resizing from origin -- left
			newWidth = initialSize.x + (start.x - event.position.x)
			newWidth = clampf(newWidth, get_combined_minimum_size().x, get_combined_maximum_size().x)
			set_position(Vector2(initialPosition.x - (newWidth - initialSize.x), get_position().y))
		
		if initialPosition.y != 0:  # If resizing from origin -- top
			newHeight = initialSize.y + (start.y - event.position.y)
			newHeight = clampf(newHeight, get_combined_minimum_size().y, get_combined_maximum_size().y)
			set_position(Vector2(get_position().x, initialPosition.y - (newHeight - initialSize.y)))
		
		set_size(Vector2(newWidth, newHeight))
		
		
	if Input.is_action_just_released("LeftClick"):
		initialPosition = Vector2(0,0)
		resizeX = false
		resizeY = false
		isResizing = false
	
	#if !isResizing:
		#_gui_input(event)

func _on_resized() ->void:
	move_area.fit_collider()
	
	header_collider.shape.size = grab_bar.get_rect().size
	header_collider.position = grab_bar.get_rect().get_center()

func _reset() ->void:
	super()
	size = reset_to_size
