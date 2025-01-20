extends CharacterBody3D

@export var jump_velocity : float = 4.5
@export var walk_speed : float = 5.0
@export var sprint_speed : float = 8.0
@export var sensitivity : float = 0.01

#head bob variables
@export var bob_freq : float = 2.0
@export var bob_amp : float = 0.08
@export var t_bob : float = 0.0 

#camera FOV
@export var base_fov : float = 75.0
@export var fov_change : float = 1.5

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

var speed := walk_speed

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(_delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * _delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	else:
		speed = walk_speed
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, _delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, _delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, _delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, _delta * 3.0)
		
		
	#Head Bob
	t_bob += _delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob(t_bob)
	
	#FOV
	var velocity_clamped  = clamp(velocity.length(), 0.5, sprint_speed * 2)
	var target_fov = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, _delta * 8.0)
	
	move_and_slide()
	
	
func headbob(time) -> Vector3:
	var pos := Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq/2) * bob_amp
	return pos
