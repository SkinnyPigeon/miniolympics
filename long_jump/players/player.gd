extends CharacterBody2D

var speed: float = 0.0
var jump_speed: float = 0.0
var max_speed: float = 300.0
var base_acceleration: float = 10.0
var base_deceleration: float = 10.0
var increased_deceleration: float = 220.0 
var gravity: int = 50

var jumped = false
var dead = false
var has_landed = false

var hold_time: float = 0.0
var max_hold_time: float = 3.0 # Maximum hold time for the angle gauge
var angle: float = 0.0
var jump_velocity: Vector2 = Vector2.ZERO

var start_position: Vector2 = Vector2.ZERO
var distance: float = 0.0

# Tilemap reference
@onready var tilemap: TileMap = get_node("../TileMap")
@onready var map_bounds = tilemap.get_used_rect()
@onready var cell_size = tilemap.tile_set.tile_size
@onready var map_width = map_bounds.size.x * cell_size.x
@onready var map_height = map_bounds.size.y * cell_size.y

@onready var camera = $Camera2D
@onready var ground: Area2D = get_node("../Ground")

@onready var distance_indicator: Label = get_node("../CanvasLayer/Panel/distance")
@onready var fault_line: Area2D = get_node("../FaultLine")
@onready var fault_line_hitbox: CollisionShape2D = get_node("../FaultLine/CollisionShape2D")
@onready var death_plane: Area2D = get_node("../DeathPlane")

# UI Elements
@onready var speed_indicator: AnimatedSprite2D = get_node("../CanvasLayer/speed")
@onready var angle_indicator: AnimatedSprite2D = get_node("../CanvasLayer/power")

func accelerate():
	var acceleration = base_acceleration * (1 - (speed / max_speed))
	speed = clamp(speed + acceleration, 0, max_speed)

func decelerate(delta):
	var deceleration = base_deceleration
	speed = max(speed - deceleration * delta, 0)

func jump():
	if dead or jumped:
		return
	jump_speed = speed
	jumped = true
	speed = 0
	$AnimatedSprite2D.play("jump")
	base_deceleration = 0.0
	var angle_radians = deg_to_rad(angle)
	jump_velocity = Vector2(jump_speed * cos(angle_radians), -jump_speed * sin(angle_radians))
	start_position = position

func angle_from_hold_time() -> float:
	return clamp(hold_time / max_hold_time * 90.0, 0, 90)

func landed():
	if not jumped:
		return
	has_landed = true
	jump_velocity = Vector2.ZERO
	$AnimatedSprite2D.play("celebrate")

func fault(ids):
	if not get_instance_id() in ids:
		return
	if jumped:
		return
	$AnimatedSprite2D.play("dead")
	angle_indicator.pause()
	dead = true
	base_acceleration = 0
	base_deceleration = 200

func death(ids):
	if not get_instance_id() in ids:
		return
	$AnimatedSprite2D.play("dead")
	angle_indicator.pause()
	dead = true
	has_landed = true
	jump_velocity.y = 0
	base_acceleration = 0
	base_deceleration = 200

func _ready():
	camera.limit_left = 0
	camera.limit_right = map_width
	camera.limit_bottom = map_height
	camera.enabled = true
	$AnimatedSprite2D.play("idle")
	ground.connect("landed", landed)
	fault_line.connect("crossed", fault)
	death_plane.connect("death", death)

func _process(delta):
	var display_speed = speed

	if jump_speed > 0.0:
		display_speed = jump_speed

	var animated_sprite = $AnimatedSprite2D

	if not dead and not jumped:
		if speed > 0:
			animated_sprite.play("run")
		if Input.is_action_just_pressed("ui_comma") or Input.is_action_just_pressed("ui_period"):
			accelerate()
		
		if Input.is_action_pressed("ui_space"):
			hold_time += delta
			angle = angle_from_hold_time()
			angle_indicator.play("power_v2")
		elif Input.is_action_just_released("ui_space"):
			angle_indicator.pause()
			jump()

	if jumped and not has_landed:
		jump_velocity.y += gravity * delta
		velocity = jump_velocity
		move_and_slide()
		
		distance = global_position.distance_to(fault_line_hitbox.global_position)
		if fault_line_hitbox.global_position.x > global_position.x:
			distance = -distance
		var to_display = distance/100
		distance_indicator.text = "%.02f" % to_display

	elif not jumped:
		decelerate(delta)
		velocity.x = speed
		move_and_slide()

	var frame = int((display_speed / max_speed) * 17)
	speed_indicator.frame = frame

	camera.position.x = clamp(camera.position.x, camera.limit_left, camera.limit_right)
	camera.position.y = clamp(camera.position.y, -100000000, map_height)
