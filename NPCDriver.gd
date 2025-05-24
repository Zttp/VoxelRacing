extends VehicleBody3D

# Настройки движения
@export var target_path: PathFollow3D
@export var max_speed: float = 15.0
@export var acceleration: float = 5.0
@export var max_steering: float = 0.8
@export var braking_distance: float = 8.0
@export var path_update_rate: float = 0.1

# Системные переменные
var current_speed: float = 0.0
var path_update_timer: float = 0.0
var target_position: Vector3 = Vector3.ZERO
var is_active: bool = true

func _ready():
    # Инициализация при старте
    if target_path:
        target_position = target_path.global_position
    engine_force = 0
    brake = 1.0 # Начинаем с зажатого тормоза

func _physics_process(delta):
    if !is_active or !target_path:
        brake = 1.0
        return
    
    # Обновление цели с заданной частотой
    path_update_timer -= delta
    if path_update_timer <= 0:
        update_target_position()
        path_update_timer = path_update_rate
    
    # Расчет направления
    var direction = target_position - global_position
    if direction.length() < 0.1:
        brake = 1.0
        return
    
    direction = direction.normalized()
    
    # Расчет поворота
    var forward = -global_transform.basis.z
    var angle = forward.signed_angle_to(direction, Vector3.UP)
    
    # Управление рулем
    steering = clamp(angle * 2.0, -max_steering, max_steering)
    
    # Управление скоростью
    var distance = global_position.distance_to(target_position)
    var target_speed = max_speed * min(1.0, distance / braking_distance)
    
    current_speed = lerp(current_speed, target_speed, acceleration * delta)
    engine_force = current_speed * 100.0
    brake = 0.0

func update_target_position():
    if !target_path:
        return
    
    # Двигаемся по пути
    target_path.progress += 1.0
    target_position = target_path.global_position
    
    # Визуализация цели (для отладки)
    DebugDraw3D.draw_sphere(target_position, 0.5, Color.RED, 1.0)

func set_active(state: bool):
    is_active = state
    if !state:
        engine_force = 0
        brake = 1.0
        steering = 0
