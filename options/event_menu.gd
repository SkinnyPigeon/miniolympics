extends Control

@export var event_scenes = {
	"100m Dash": "res://100m/track/track.tscn",
	"Javelin": "res://javelin/track/track.tscn",
	"Long Jump": "res://long_jump/track/track.tscn"
}

var current_selection: int = 0
var event_labels: Array[Label] = []

func _ready():
	var vbox = $VBoxContainer
	for child in vbox.get_children():
		if child is Label:
			event_labels.append(child)
	update_selection()

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		current_selection = (current_selection - 1 + event_labels.size()) % event_labels.size()
		update_selection()
	elif Input.is_action_just_pressed("ui_down"):
		current_selection = (current_selection + 1) % event_labels.size()
		update_selection()
	elif Input.is_action_just_pressed("ui_accept"):
		start_selected_event()

func update_selection():
	for i in range(event_labels.size()):
		var label = event_labels[i]
		if i == current_selection:
			label.add_theme_color_override("font_color", Color(1, 1, 0))
		else:
			label.add_theme_color_override("font_color", Color(1, 1, 1))

func start_selected_event():
	var event_name = event_labels[current_selection].text
	var event_scene_path = event_scenes[event_name]
	get_tree().change_scene_to_file(event_scene_path)
