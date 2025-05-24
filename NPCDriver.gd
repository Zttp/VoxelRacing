extends VehicleBody3D

@export var target_path: PathFollow3D
@export var speed: float = 10.0

func _physics_process(delta):
    if target_path:
        var target_pos = target_path.global_transform.origin
        var direction = (target_pos - global_transform.origin).normalized()
        var angle_to_target = global_transform.basis.z.angle_to(direction)
        
        # Поворот к цели
        steering = clamp(angle_to_target * 2.0, -0.5, 0.5)
        engine_force = speed
