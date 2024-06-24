extends CharacterBody2D

var wheel_base = 70 # Distance from front to rear wheel
var steering_angle = 15 # Amount that front wheel turns, in degrees
var engine_power = 900 # Forward acceleration force
var friction = -55
var drag = -0.06
var braking = -450
var max_speed_reverse = 250

var push_force = 1400.0
var acceleration: Vector2
var steer_direction


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()


func start(pos):
	rotation_degrees = -90
	position = pos
	show()
	

func get_input():
	var turn = Input.get_axis("steer_left", "steer_right")
	steer_direction = turn * deg_to_rad(steering_angle)
	
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking
	

func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += friction_force + drag_force


func calculate_steering(delta):
	# 1. Find the wheel positions
	var rear_wheel: Vector2 = position - transform.x * wheel_base / 2
	var front_wheel: Vector2 = position + transform.x * wheel_base / 2
	
	# 2. Move the wheels forward
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	
	# 3. Find the new direction vector
	var new_heading = rear_wheel.direction_to(front_wheel)
	var d = new_heading.dot(velocity.normalized())
	
	# 4. Set the velocity and rotation to the new direction
	if d > 0:
		velocity = new_heading * velocity.length()
	elif d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()
