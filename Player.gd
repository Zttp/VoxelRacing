extends CharacterBody3D

@export var speed: float = 5.0
@export var acceleration: float = 10.0
@export var jump_velocity: float = 4.5
@export var rotation_speed: float = 10.0
@export var sprint_multiplier: float = 1.5

var gravity = 9.8
var current_vehicle: VehicleBody3D = null
var is_in_vehicle: bool = false
var can_exit_vehicle = false

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var interaction_area = $InteractionArea

func _ready():
    # Убедимся, что камера активна при старте
    camera.current = true

func _input(event):
    if event.is_action_pressed("jump") and is_on_floor() and !is_in_vehicle:
        velocity.y = jump_velocity
        
    if is_in_vehicle:
        if event.is_action_pressed("interact") and can_exit_vehicle:
            current_vehicle.exit_vehicle()
            is_in_vehicle = false
        return
        
    if event.is_action_pressed("interact") and is_near_vehicle():
        enter_nearest_vehicle()

func is_near_vehicle():
    for body in interaction_area.get_overlapping_bodies():
        if body is VehicleBody3D and body.has_method("enter_vehicle"):
            current_vehicle = body
            return true
    return false
    
func enter_nearest_vehicle():
    if current_vehicle != null and !is_in_vehicle:
        if !current_vehicle.can_enter(global_position):
            print("Подойдите ближе к двери водителя")
            return
            
        if current_vehicle.enter_vehicle(self):
            is_in_vehicle = true
            can_exit_vehicle = false
            camera.current = false
            $CollisionShape3D.disabled = true
            
            # Ждем немного перед выходом
            await get_tree().create_timer(1.0).timeout
            can_exit_vehicle = true

func exit_vehicle(exit_transform: Transform3D):
    if !is_in_vehicle:
        return
        
    is_in_vehicle = false
    can_exit_vehicle = false
    
    # Восстанавливаем управление игроком
    camera.current = true
    $CollisionShape3D.disabled = false
    
    # Устанавливаем позицию выхода
    global_transform = exit_transform
    
    # Ждем немного перед повторным входом
    await get_tree().create_timer(1.0).timeout

func _physics_process(delta):
    if is_in_vehicle:
        return  # Не обрабатываем движение, когда в транспортном средстве

    # Гравитация
    if not is_on_floor():
        velocity.y -= gravity * delta

    # Управление движением
    var input_dir = Input.get_vector("left", "right", "up", "down")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    # Спринт
    var current_speed = speed
    if Input.is_action_pressed("sprint"):
        current_speed *= sprint_multiplier
    
    if direction:
        velocity.x = direction.x * current_speed
        velocity.z = direction.z * current_speed
    else:
        velocity.x = move_toward(velocity.x, 0, acceleration * delta)
        velocity.z = move_toward(velocity.z, 0, acceleration * delta)
    
    move_and_slide()

    # Поворот камеры
    if Input.is_action_pressed("camera_left"):
        rotate_y(rotation_speed * delta)
    if Input.is_action_pressed("camera_right"):
        rotate_y(-rotation_speed * delta)
