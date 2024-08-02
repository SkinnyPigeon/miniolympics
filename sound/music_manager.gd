extends Node

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
var music_tracks: Array[AudioStream] = []
var current_track_index: int = 0

func _ready():
	load_music_tracks()
	shuffle_music()
	play_next_track()
	#audio_player.connect("finished", _on_audio_player_finished)

func load_music_tracks():
	var music_folder = "res://sound/music"
	var dir = DirAccess.open(music_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() and file_name.ends_with(".mp3"):
				var music_path = music_folder + "/" + file_name
				var music_stream = load(music_path) as AudioStream
				music_tracks.append(music_stream)
			file_name = dir.get_next()
		dir.list_dir_end()

func shuffle_music():
	randomize()
	music_tracks.shuffle()

func play_next_track():
	if music_tracks.size() > 0:
		audio_player.stream = music_tracks[current_track_index]
		audio_player.play()
		current_track_index = (current_track_index + 1) % music_tracks.size()


func _on_audio_stream_player_2d_finished():
	play_next_track()
