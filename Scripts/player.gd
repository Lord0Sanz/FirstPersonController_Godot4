extends CharacterBody3D

var speed
@export var WALK_SPEED = 5.0
@export var SPRINT_SPEED = 8.0
@export var JUMP_VELOCITY = 4.5

# Mouse sensitivity
@export var mouse_sensitivity: float = 0.3

# Get the gravity from the project settings
@export var gravity = 9.8

@onready var camera = $head
@onready var camera_3d = $head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_camera(event.relative)
	if event.is_action_pressed("exit"):
		_exit_game()

func rotate_camera(relative_motion: Vector2):
	camera.rotate_y(-relative_motion.x * mouse_sensitivity * get_process_delta_time())
	camera_3d.rotate_x(-relative_motion.y * mouse_sensitivity * get_process_delta_time())
	camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-40), deg_to_rad(40))

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	move_and_slide()

func _exit_game():
	get_tree().quit()
