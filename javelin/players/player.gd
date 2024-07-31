extends CharacterBody2D

var speed: float = 0.0
var max_speed: float = 300.0
var base_acceleration: float = 10.0
var base_deceleration: float = 5.0
var increased_deceleration: float = 220.0 
var thrown = false
var dead = false

# Tilemap reference
@onready var tilemap: TileMap = get_node("../TileMap")
@onready var map_bounds = tilemap.get_used_rect()
@onready var cell_size = tilemap.tile_set.tile_size
@onready var map_width = map_bounds.size.x * cell_size.x

# UI Elements
@onready var speed_indicator: AnimatedSprite2D = get_node("../CanvasLayer/speed")
@onready var angle_indicator: AnimatedSprite2D = get_node("../CanvasLayer/power")


@onready var fault_line: Area2D = get_node("../FaultLine")
const JAVELIN = preload("res://javelin/players/javelin.tscn")

var hold_time: float = 0.0
var max_hold_time: float = 3.0 # Maximum hold time for the angle gauge
var angle: float = 0.0

func angle_from_hold_time() -> float:
	return clamp(hold_time / max_hold_time * 90.0, 0, 90)


func fault(ids):
	if not get_instance_id() in ids:
		return
	$AnimatedSprite2D.play("dead")
	dead = true
	base_acceleration = 0
	base_deceleration = 200

func throw():
	if dead or thrown:
		return
	thrown = true
	$AnimatedSprite2D.play("throw")
	await $AnimatedSprite2D.animation_looped
	var camera: Camera2D = $Camera2D
	camera.enabled = false
	var javelin = JAVELIN.instantiate()
	add_child(javelin)
	javelin.velocity = velocity
	javelin.set_speed(speed)
	javelin.set_angle(angle)
	$AnimatedSprite2D.play("throw_recovery")
	base_acceleration = 0
	base_deceleration = 800
	await $AnimatedSprite2D.animation_looped
	$AnimatedSprite2D.play("run")

func accelerate():
	var acceleration = base_acceleration * (1 - (speed / max_speed))
	speed = clamp(speed + acceleration, 0, max_speed)

func decelerate(delta):
	var deceleration = base_deceleration
	speed = max(speed - deceleration * delta, 0)


func _ready():
	$AnimatedSprite2D.play("idle")
	fault_line.connect("crossed", fault)

func _process(delta):
	var camera: Camera2D = $Camera2D
	if not thrown:
		camera.limit_left = 0
		camera.limit_right = map_width
		camera.limit_top = 0
		camera.enabled = true
		var viewport_center_x = get_viewport().size.x / 2

		if position.x > viewport_center_x:
			camera.position.x = position.x - viewport_center_x
		else:
			camera.position.x = 0  
		camera.position.x = clamp(camera.position.x, camera.limit_left, camera.limit_right)
	var animated_sprite = $AnimatedSprite2D
	if not dead and not thrown:
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
			throw()
	
	if speed <= 0 and not dead and not thrown:
		animated_sprite.play("idle")
	if dead:
		animated_sprite.play("dead")
	if thrown and speed <= 0 and not dead:
		animated_sprite.play("celebrate")

	if not Input.is_action_pressed("ui_space"):
		decelerate(delta)
		velocity.x = speed
		move_and_slide()

	var frame = int((speed / max_speed) * 17)
	speed_indicator.frame = frame
