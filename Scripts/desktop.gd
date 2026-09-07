extends Control

@onready var installer_icon: TextureButton = $BG/InstallerIcon
@onready var trash_icon: TextureButton = $BG/VBoxContainer/MarginContainer/HFlowContainer/TrashIcon
@onready var folder_icon: TextureButton = $BG/VBoxContainer/MarginContainer/HFlowContainer/FolderIcon
@onready var credits_icon: TextureButton = $BG/VBoxContainer/MarginContainer/HFlowContainer/CreditsIcon

@onready var credits_window: UIWindow = $AppWindows/CreditsWindow

signal installer_start

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	installer_icon.pressed.connect(_on_installer_selected)


func _on_installer_selected() ->void:
	installer_start.emit()

func _on_trash_selected() ->void:
	pass

func _on_folder_selected() ->void:
	pass

func _on_credits_selected() ->void:
	credits_window.enter()
