extends CharacterBody2D

var has_finished: bool = false

# Base speed parameters
var base_max_speed: float = 295.0
var base_acceleration: float = 50.0
var base_deceleration: float = 20.0

# Randomized speed parameters
var max_speed: float
var acceleration: float
var deceleration: float

# Speed fluctuation parameters
var fluctuation_frequency: float = 0.5  # Time in seconds between fluctuations
var fluctuation_amplitude: float = 5.0  # Maximum change in speed during fluctuations

# Internal variables
var speed: float = 0.0
var timer: float = 0.0

@onready var start_timer: Timer = get_node("../../HUD/start_timer/Timer")
@onready var finish_line: Area2D = get_node("../../FinishLine")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func finished(ids):
	if get_instance_id() in ids:
		has_finished = true

func decelerate(delta):
	speed = max(speed - 220 * delta, 0)

func _ready():
	randomize()
	# Initialize random stats
	max_speed = base_max_speed + randf_range(-20.0, 20.0)
	acceleration = base_acceleration + randf_range(-10.0, 10.0)
	deceleration = base_deceleration + randf_range(-5.0, 5.0)
	finish_line.connect("finished", finished)
	animated_sprite.play("idle")

func _process(delta):
	if not start_timer.is_stopped():
		return
	# Simple AI to maintain speed with slight fluctuation
	timer += delta
	if not has_finished:
		if timer >= fluctuation_frequency:
			timer = 0.0
			# Apply a small random fluctuation to the speed
			speed += randf_range(-fluctuation_amplitude, fluctuation_amplitude)
			speed = clamp(speed, 0, max_speed)

		# Accelerate to target speed
		if speed < max_speed:
			speed = min(speed + acceleration * delta, max_speed)

		# Decelerate if over max speed (fluctuation may cause this)
		if speed > max_speed:
			speed = max(speed - deceleration * delta, 0)
	else:
		decelerate(delta)
	# Move the character
	velocity.x = speed
	move_and_slide()

	# Handle animations
	
	if speed > 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
