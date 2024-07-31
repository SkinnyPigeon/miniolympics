extends Panel

var time: float = 0.0
var seconds: float = 0.0
var milisecs: float = 0.0
var run: bool = true
@onready var start_timer: Timer = get_node("../../HUD/start_timer/Timer")

func show_time(delta):
	time += delta
	seconds = fmod(time, 60)
	milisecs = fmod(time, 1) * 100
	$Seconds.text = "%02d." % seconds
	$Miliseconds.text = "%03d" % milisecs

func stop():
	run = false

func _process(delta):
	if not start_timer.is_stopped():
		return
	if not run:
		return
	show_time(delta)
