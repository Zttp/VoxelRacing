extends VehicleBody3D

@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.6
@export var engine_force_value = 40
@export var max_exit_speed: float = 100
@export var max_entry_speed: float = 5.0

var steer_target = 0
var driver = null
var can_accelerate = false

@onready var exit_point = $ExitPoint
@onready var driver_seat = $DriverSeat
@onready var vehicle_camera = $look/Camera3D

func _physics_process(delta):
    if driver and can_accelerate:
        handle_driving_controls(delta)

func handle_driving_controls(delta):
    # Steering
    steer_target = Input.get_action_strength("left") - Input.get_action_strength("right")
    steer_target *= STEER_LIMIT
    steering = move_toward(steering, steer_target, STEER_SPEED * delta)
    
    # Acceleration/Braking
    if Input.is_action_pressed("backward"):
        engine_force = -engine_force_value
    elif Input.is_action_pressed("forward"):
        engine_force = engine_force_value
    else:
        engine_force = 0
        brake = 1.0

func enter_vehicle(player):
    if !can_enter(player.global_position):
        return false
        
    driver = player
    vehicle_camera.current = true
    can_accelerate = true
    
    # Сразу скрываем модель игрока
    driver.visible = false
    
    # Перемещаем игрока в сиденье
    driver.global_transform = driver_seat.global_transform
    
    return true

func exit_vehicle():
    if !driver: return
    
    can_accelerate = false
    engine_force = 0
    brake = 10.0
    
    # Показываем игрока
    driver.visible = true
    driver.global_transform = exit_point.global_transform
    
    # Возвращаем камеру игроку
    vehicle_camera.current = false
    
    # Освобождаем управление
    driver = null

func can_enter(player_position: Vector3) -> bool:
    return linear_velocity.length() <= max_entry_speed
