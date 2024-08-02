extends Control

var current_selection: int = 0
var menu_labels: Array[Label] = []

@onready var event_scene_path: String = ""

func _ready():
	var vbox = $VBoxContainer
	for child in vbox.get_children():
		if child is Label:
			menu_labels.append(child)
	update_selection()
	hide()

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		current_selection = (current_selection - 1 + menu_labels.size()) % menu_labels.size()
		update_selection()
	elif Input.is_action_just_pressed("ui_down"):
		current_selection = (current_selection + 1) % menu_labels.size()
		update_selection()
	elif Input.is_action_just_pressed("ui_enter"):
		process_selection()


func update_selection():
	for i in range(menu_labels.size()):
		var label = menu_labels[i]
		if i == current_selection:
			label.add_theme_color_override("font_color", Color(1, 1, 0))
		else:
			label.add_theme_color_override("font_color", Color(1, 1, 1))

func process_selection():
	if current_selection == 0:  # Retry
		get_tree().change_scene_to_file(event_scene_path)
	elif current_selection == 1:  # Main Menu
		get_tree().change_scene_to_file("res://options/event_menu.tscn")
