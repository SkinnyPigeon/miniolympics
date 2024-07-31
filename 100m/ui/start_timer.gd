extends Panel

var time: float = 1.0
var seconds: float = 0.0
var milisecs: float = 0.0
@onready var timer: Timer = $Timer

func _process(_delta):
	if timer.is_stopped():
		$Seconds.text = ""
		$Miliseconds.text = ""
		$Go.text = "Go go go!"
	else:
		time = timer.time_left
		seconds = fmod(time, 60)
		milisecs = fmod(time, 1) * 100
		$Seconds.text = "%02d." % seconds
		$Miliseconds.text = "%03d" % milisecs
