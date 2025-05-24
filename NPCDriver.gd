extends VehicleBody3D

@export var target_path: PathFollow3D
@export var speed: float = 10.0
@export var max_steering_angle: float = 0.5
@export var braking_distance: float = 5.0

var is_active: bool = true

func _physics_process(delta):
    if !is_active or !target_path:
        return
        
    var target_pos = target_path.global_transform.origin
    var direction = target_pos - global_transform.origin
    
    # Проверка нулевого вектора
    if direction.length_squared() < 0.1:
        engine_force = 0
        return
    
    direction = direction.normalized()
    
    # Расчет поворота с защитой от NaN
    var forward = -global_transform.basis.z.normalized()
    var angle_to_target = forward.signed_angle_to(direction, Vector3.UP)
    
    if is_nan(angle_to_target):
        angle_to_target = 0.0
    
    # Плавный поворот
    steering = clamp(angle_to_target * 2.0, -max_steering_angle, max_steering_angle)
    
    # Торможение при приближении
    var distance = global_transform.origin.distance_to(target_pos)
    if distance < braking_distance:
        engine_force = lerp(0.0, speed, distance / braking_distance)
    else:
        engine_force = speed

func set_active(state: bool):
    is_active = state
    if !state:
        engine_force = 0
        steering = 0
