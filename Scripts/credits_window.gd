extends Control

var start_position : Vector2
var move_start : Vector2
var drag_start : Vector2
var is_draggable := true
var grabbed := false

@onready var grab_bar: PanelContainer = %GrabBar
@onready var window_title: Label = %WindowTitle

#signal window_tab_changed(index:int)
#signal window_selected(window:WindowPanel)
#signal window_grabbed(window:WindowPanel)
#signal window_released(window:WindowPanel)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = global_position
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = move_start + (get_global_mouse_position() - drag_start)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("LeftClick") && grabbed:
		drag_start = get_global_mouse_position()
		move_start = global_position
		set_process(true)
	elif event.is_action_released("LeftClick"):
		set_process(false)

func open() ->void:
	# popup anim ?
	show()
func close() ->void:
	# close anim ?
	hide()

#func toggle_minimized() ->void:
	#minimized = !minimized
	#move_panel.visible = !minimized
	#move_area.monitorable = !minimized
	#move_area.monitoring = !minimized

func _on_grab_bar_entered() ->void:
	grabbed = true
func _on_grab_bar_exited() ->void:
	grabbed = false

func _on_resized() ->void:
	return
	print(name + "resized. Size: ", size)

func _reset() ->void:
	global_position = start_position
