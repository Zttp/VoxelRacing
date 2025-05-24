extends VehicleBody3D

@export var target_path: PathFollow3D
@export var speed: float = 10.0
@export var max_steering_angle: float = 0.5
@export var braking_distance: float = 5.0
@export var path_offset_speed: float = 1.0

var is_active: bool = true
var safe_direction: Vector3 = Vector3.FORWARD

func _ready():
    # Инициализация начального направления
    safe_direction = -global_transform.basis.z

func _physics_process(delta):
    if !is_active or !target_path or !target_path.get_parent() is Path3D:
        engine_force = 0
        return
    
    # Плавное движение по пути
    target_path.progress += path_offset_speed * delta
    
    var target_pos = target_path.global_transform.origin
    var direction = target_pos - global_transform.origin
    
    # Полная защита от нулевого вектора
    if direction.length_squared() < 0.01:
        engine_force = 0
        steering = 0
        return
    
    direction = direction.normalized()
    
    # Альтернативный расчет угла без использования angle_to
    var forward = -global_transform.basis.z
    var cross = forward.cross(direction)
    var angle_to_target = atan2(cross.length(), forward.dot(direction)) * sign(cross.y)
    
    # Подавление NaN/Inf
    if is_nan(angle_to_target) or is_inf(angle_to_target):
        angle_to_target = 0.0
        direction = safe_direction
    else:
        safe_direction = direction
    
    # Плавный поворот с ограничением
    steering = move_toward(
        steering,
        clamp(angle_to_target * 2.0, -max_steering_angle, max_steering_angle),
        delta * 2.0
    )
    
    # Адаптивное ускорение/торможение
    var distance = global_transform.origin.distance_to(target_pos)
    engine_force = speed * smoothstep(0.0, braking_distance, distance)

# Плавная интерполяция (аналог smoothstep в Godot)
func smoothstep(edge0: float, edge1: float, x: float) -> float:
    x = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return x * x * (3.0 - 2.0 * x)

func set_active(state: bool):
    is_active = state
    if !state:
        engine_force = 0
        steering = 0
