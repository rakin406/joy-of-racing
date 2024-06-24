extends CharacterBody2D

var engine_power = 900
var max_speed = 470
var steer_force = 0.2
var look_ahead = 200
var num_rays = 32

# Context array
var ray_directions = []
var interest = []
var danger = []

var chosen_dir = Vector2.ZERO
var acceleration = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)


func _physics_process(delta):
	# Populate context arrays
	set_interest()
	set_danger()
	choose_direction()
	
	# Movement
	acceleration = transform.x * engine_power
	var desired_velocity = chosen_dir.rotated(rotation) * max_speed
	velocity = velocity.lerp(desired_velocity, steer_force)
	velocity += acceleration * delta
	rotation = velocity.angle()
	move_and_slide()


func start(pos):
	rotation_degrees = -90
	position = pos
	show()


func set_interest():
	# Set interest in each slot based on world direction
	if owner and owner.has_method("get_path_direction"):
		var path_direction = owner.get_path_direction(position)
		for i in num_rays:
			var d = ray_directions[i].rotated(rotation).dot(path_direction)
			interest[i] = max(0, d)
	# If no world direction, use default interest
	else:
		set_default_interest()


func set_default_interest():
	# Default to moving forward
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(transform.x)
		interest[i] = max(0, d)


func set_danger():
	# Cast rays to find danger directions
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsRayQueryParameters2D.new()
	params.from = position
	params.exclude = [self]
	
	for i in num_rays:
		params.to = position + ray_directions[i].rotated(rotation) * look_ahead
		var result = space_state.intersect_ray(params)
		danger[i] = 1.0 if result else 0.0


func choose_direction():
	# Eliminate interest in slots with danger
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	
	# Choose direction based on remaining interest
	chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()
