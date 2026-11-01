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

signal window_resize_start(window:ResizableWindow)
signal window_resized(window:ResizableWindow)
signal window_resize_end(window:ResizableWindow)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	window_icon = ICON_TYPE.RESIZABLE
	super()
	reset_to_size = size

func _gui_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		grab()
		if dragging:
			return
		
		var rect := get_global_rect()
		var localMousePos : Vector2 = event.position
		
		if abs(localMousePos.x - rect.size.x) < ResizeThreshold:
			start.x = get_global_mouse_position().x #event.position.x
			initialSize.x = get_size().x
			resizeX = true
			isResizing = true
		
		if abs(localMousePos.y - rect.size.y) < ResizeThreshold:
			start.y = get_global_mouse_position().y #event.position.y
			initialSize.y = get_size().y
			resizeY = true
			isResizing = true
		
		if localMousePos.x < ResizeThreshold && localMousePos.x > -ResizeThreshold:
			start.x = get_global_mouse_position().x #event.position.x
			initialPosition.x = get_global_position().x
			initialSize.x = get_size().x
			isResizing = true
			resizeX = true
		
		if localMousePos.y < ResizeThreshold && localMousePos.y > -ResizeThreshold:
			start.y = get_global_mouse_position().y #event.position.y
			initialPosition.y = get_global_position().y
			initialSize.y = get_size().y
			isResizing = true
			resizeY = true
		
		window_resize_start.emit(self)
	
	elif Input.is_action_pressed("LeftClick"):
		if dragging:
			super(event)
		else:
			resize_window()
	
	if Input.is_action_just_released("LeftClick"):
		if dragging:
			release()
			return
		
		initialPosition = Vector2(0,0)
		resizeX = false
		resizeY = false
		isResizing = false
		move_area.fit_collider()
		window_resize_end.emit(self)


func resize_window() ->void:
	var newWidth := get_size().x
	var newHeight := get_size().y
	var event_position : Vector2 = get_global_mouse_position()
	
	#print("globalmouse: ", get_global_mouse_position(), ", globalpos: ", global_position)
	#print("EventPos: ", event_position, ", initial_position: ", initialPosition, ", initialsize: ", initialSize, ", start: ", start)
	
	if resizeX:
		newWidth = initialSize.x - (start.x - event_position.x) 
	
	if resizeY:
		newHeight = initialSize.y - (start.y - event_position.y)
	
	if initialPosition.x != 0: # If resizing from origin -- left
		newWidth = initialSize.x + (start.x - event_position.x) # x = 180 + (1 - -80) = 261 | 180 + (1 + 83) = 264
		newWidth = clampf(newWidth, get_combined_minimum_size().x, get_combined_maximum_size().x)
		set_position(Vector2(initialPosition.x - (newWidth - initialSize.x), get_position().y)) # x = 636 - (261-180)=556 | 636 - (264-180)=552
	
	if initialPosition.y != 0:  # If resizing from origin -- top
		newHeight = initialSize.y + (start.y - event_position.y)
		newHeight = clampf(newHeight, get_combined_minimum_size().y, get_combined_maximum_size().y)
		set_position(Vector2(get_position().x, initialPosition.y - (newHeight - initialSize.y)))
	
	set_size(Vector2(newWidth, newHeight))

func _on_resized() ->void:
	print("--_on_resize")
	move_area.fit_collider()
	#header_collider.shape.size = grab_bar.get_rect().size
	#header_collider.position = grab_bar.get_rect().get_center()
	window_resized.emit(self)
	

func _reset() ->void:
	super()
	size = reset_to_size
