class_name TabWindow extends WindowPanel

const TAB_NAMES := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const TAB_TITLE_FORMAT := " %s "

var selected_tab := -1

## Starting selected tab, defaults to tab 0
@export var start_tab := 0
@export var tab_controls : Array[Control]

@onready var tab_bar: TabBar = %TabBar

signal window_tab_changed(index:int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	tab_bar.clear_tabs()
	selected_tab = start_tab
	
	for i : int in range(tab_controls.size()):
		tab_bar.add_tab(TAB_TITLE_FORMAT % TAB_NAMES.substr(i, 1))
	
	tab_bar.current_tab = selected_tab
	tab_bar.tab_changed.emit(tab_bar.current_tab) # a bit ugly but whatever
	show_tab_content(-1)

func enter() ->void:
	await super()
	show_tab_content(selected_tab)


func _on_tab_changed(index:int) ->void:
	if tab_controls.size() == 0:
		return
	
	selected_tab = index
	show_tab_content(selected_tab)
	
	window_tab_changed.emit(index)
	print("Tab changed: ", index)

func show_tab_content(tab:int) ->void:
	for tab_control in tab_controls:
		tab_control.hide()
	
	if tab < 0:
		return
	
	tab_controls[tab].show()

func _reset() ->void:
	super()
	tab_bar.current_tab = start_tab
