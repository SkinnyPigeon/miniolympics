extends CharacterBody2D

var speed: float = 0.0
var gravity: float = 20.0
var javelin_velocity: Vector2 = Vector2.ZERO
var is_flying: bool = true

# Tilemap reference
@onready var tilemap: TileMap = get_node("../../TileMap")
@onready var map_bounds = tilemap.get_used_rect()
@onready var cell_size = tilemap.tile_set.tile_size
@onready var map_width = map_bounds.size.x * cell_size.x
@onready var map_height = map_bounds.size.y * cell_size.y
@onready var camera = $Camera2D
@onready var ground: Area2D = get_node("../../Ground")

@onready var distance_indicator: Label = get_node("../../CanvasLayer/Panel/distance")
@onready var fault_line: CollisionShape2D = get_node("../../FaultLine/CollisionShape2D")

var start_position: Vector2 = Vector2.ZERO
var distance: float = 0.0

func set_speed(player_speed):
	speed = player_speed

func set_angle(angle):
	rotation = deg_to_rad(-angle)
	javelin_velocity = Vector2(speed, 0).rotated(rotation)
	start_position = position

func landed():
	is_flying = false
	javelin_velocity = Vector2.ZERO
	print_debug(distance)

func _ready():
	camera.limit_left = 0
	camera.limit_right = map_width
	camera.limit_bottom = map_height
	camera.enabled = true
	ground.connect("landed", landed)

func _process(delta):
	if is_flying:
		javelin_velocity.y += gravity * delta 
		velocity = javelin_velocity 
		rotation = javelin_velocity.angle()
		move_and_slide()
		
		distance = global_position.distance_to(fault_line.global_position)
		if fault_line.global_position.x > global_position.x:
			distance = -distance
		var to_display = distance/35
		distance_indicator.text = "%.02f" % to_display
		
	camera.position.x = clamp(camera.position.x, camera.limit_left, camera.limit_right)
	camera.position.y = clamp(camera.position.y, -100000000, map_height)
