extends CharacterBody3D

@export var speed: float = 5.0
@export var acceleration: float = 10.0
@export var jump_velocity: float = 4.5
@export var rotation_speed: float = 10.0

var gravity = 9.8
var current_vehicle: VehicleBody3D = null
var is_in_vehicle: bool = false

@onready var camera = $CameraPivot/Camera3D
@onready var interaction_area = $InteractionArea

func _ready():
    camera.current = true

func _input(event):
    if event.is_action_pressed("jump") and is_on_floor() and !is_in_vehicle:
        velocity.y = jump_velocity
        
    if event.is_action_pressed("interact"):
        if is_in_vehicle:
            current_vehicle.exit_vehicle()
            is_in_vehicle = false
            camera.current = true
        elif is_near_vehicle():
            enter_nearest_vehicle()

func is_near_vehicle():
    for body in interaction_area.get_overlapping_bodies():
        if body is VehicleBody3D and body.has_method("enter_vehicle"):
            current_vehicle = body
            return true
    return false
    
func enter_nearest_vehicle():
    if current_vehicle and current_vehicle.enter_vehicle(self):
        is_in_vehicle = true
        camera.current = false

func _physics_process(delta):
    if is_in_vehicle:
        return

    # Гравитация
    if not is_on_floor():
        velocity.y -= gravity * delta

    # Управление движением
    var input_dir = Input.get_vector("left", "right", "up", "down")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, acceleration * delta)
        velocity.z = move_toward(velocity.z, 0, acceleration * delta)
    
    move_and_slide()
