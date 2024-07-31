extends CharacterBody2D

# Speed parameters
var speed: float = 0.0
var max_speed: float = 300.0
var base_acceleration: float = 10.0
var base_deceleration: float = 5.0
var increased_deceleration: float = 220.0 
var has_finished: bool = false


# Timer node reference
@onready var deceleration_timer: Timer = get_node("../DecelerationTimer")
# Tilemap reference
@onready var tilemap: TileMap = get_node("../../TileMap")
# UI speed indicator reference
@onready var speed_indicator: AnimatedSprite2D = get_node("../../HUD/speed")

@onready var start_timer: Timer = get_node("../../HUD/start_timer/Timer")

@onready var finish_line: Area2D = get_node("../../FinishLine")

@onready var stop_watch: Panel = get_node("../../HUD/StopWatch")


func finished(ids):
	if get_instance_id() in ids:
		stop_watch.stop()
		base_acceleration = 0
		base_deceleration = 220

func accelerate():
	var acceleration = base_acceleration * (1 - (speed / max_speed))
	speed = clamp(speed + acceleration, 0, max_speed)

func decelerate(delta):
	var deceleration = base_deceleration
	if deceleration_timer.time_left == 0:
		deceleration = increased_deceleration
	speed = max(speed - deceleration * delta, 0)

func _ready():
	finish_line.connect("finished", finished)
	var map_bounds = tilemap.get_used_rect()
	var cell_size = tilemap.tile_set.tile_size
	var map_width = map_bounds.size.x * cell_size.x

	var camera: Camera2D = $Camera2D
	camera.limit_left = 0
	camera.limit_right = map_width
	camera.limit_top = 0

func _process(delta):
	var animated_sprite = $AnimatedSprite2D
	if speed > 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
	
	if not start_timer.is_stopped():
		return
		
	if has_finished:
		return
	
	if Input.is_action_just_pressed("ui_comma") or Input.is_action_just_pressed("ui_period"):
		accelerate()
		deceleration_timer.start()

	decelerate(delta)
	velocity.x = speed
	move_and_slide()


	var camera = $Camera2D
	var viewport_center_x = get_viewport().size.x / 2

	if position.x > viewport_center_x:
		camera.position.x = position.x - viewport_center_x
	else:
		camera.position.x = 0  
	camera.position.x = clamp(camera.position.x, camera.limit_left, camera.limit_right)

	var frame = int((speed / max_speed) * 17)
	speed_indicator.frame = frame
