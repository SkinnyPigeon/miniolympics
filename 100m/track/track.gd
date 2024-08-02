extends Node2D


@onready var pause_menu: Control = $HUD/PauseMenu
@onready var event_scene_path: String = ""

func _ready():
	event_scene_path = get_tree().current_scene.scene_file_path
	pause_menu.event_scene_path = event_scene_path
	pause_menu.hide()

func _input(event):
	if event.is_action_pressed("ui_pause"): 
		toggle_pause()

#
func toggle_pause():
	if pause_menu.visible:
		pause_menu.hide()
	else:
		pause_menu.show()
