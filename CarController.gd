extends VehicleBody3D

class_name CarController

## === НАСТРОЙКИ МАШИНЫ === ##
@export_category("Car Info")
@export var car_name: String = "Бананомобиль"
@export_multiline var car_description: String = "Древний автомобиль на банановом топливе"
@export var price: int = 1000
@export var currency: String = "🍌"

@export_category("Performance")
@export var max_speed: float = 30.0    # км/ч (конвертируем в м/с)
@export var engine_power: float = 150.0
@export var brake_power: float = 500.0
@export var steering_speed: float = 0.8
@export var grip: float = 0.9          # 0.1-1.0

@export_category("Wheels")
@export var front_left_wheel: VehicleWheel3D
@export var front_right_wheel: VehicleWheel3D
@export var rear_left_wheel: VehicleWheel3D
@export var rear_right_wheel: VehicleWheel3D

## === ПЕРЕМЕННЫЕ === ##
var _current_speed: float = 0.0
var _is_engine_running: bool = false
var _steering: float = 0.0
var _effective_grip: float = 1.0

# Тюнинг
var _upgrades = {
    "engine": 0,
    "suspension": 0,
    "brakes": 0
}

func _ready():
    _apply_car_settings()
    
    # Конвертируем км/ч в м/с для внутренних расчётов
    max_speed = (max_speed * 1000) / 3600

func _apply_car_settings():
    # Настройка колёс
    for wheel in [front_left_wheel, front_right_wheel, rear_left_wheel, rear_right_wheel]:
        wheel.wheel_friction_slip = 10.0 * grip
        wheel.suspension_stiffness = 50.0
        wheel.suspension_max_force = 10000
        
        # Регулировка в зависимости от тюнинга
        wheel.suspension_stiffness += 5.0 * _upgrades["suspension"]
        wheel.wheel_friction_slip += 0.5 * _upgrades["engine"]

func _physics_process(delta):
    _handle_input(delta)
    _calculate_speed()
    _apply_steering(delta)
    _apply_drift()

func _handle_input(delta):
    # Газ/тормоз
    var throttle = Input.get_axis("brake", "accelerate")
    
    if throttle > 0:
        engine_force = throttle * (engine_power + 20 * _upgrades["engine"])
    else:
        brake = abs(throttle) * (brake_power + 50 * _upgrades["brakes"])

    # Ручной тормоз для дрифта
    if Input.is_action_pressed("handbrake"):
        rear_left_wheel.wheel_friction_slip = 0.1
        rear_right_wheel.wheel_friction_slip = 0.1
    else:
        rear_left_wheel.wheel_friction_slip = 10.0 * grip
        rear_right_wheel.wheel_friction_slip = 10.0 * grip

func _calculate_speed():
    _current_speed = linear_velocity.length()
    
    # Ограничение скорости
    if _current_speed > max_speed:
        var speed_reduction = (_current_speed - max_speed) * 0.1
        linear_velocity -= linear_velocity.normalized() * speed_reduction

func _apply_steering(delta):
    var steer_input = Input.get_axis("steer_left", "steer_right")
    _steering = move_toward(_steering, 
                          steer_input * deg_to_rad(30.0), 
                          steering_speed * delta)
    
    front_left_wheel.steering = _steering
    front_right_wheel.steering = _steering

func _apply_drift():
    # Реалистичный занос
    var lateral_velocity = global_transform.basis.x.dot(linear_velocity)
    var lateral_factor = abs(lateral_velocity) / max_speed
    _effective_grip = grip * (1.0 - clamp(lateral_factor, 0.0, 0.8))
    
    for wheel in [front_left_wheel, front_right_wheel, rear_left_wheel, rear_right_wheel]:
        wheel.wheel_friction_slip = 10.0 * _effective_grip

## === API ДЛЯ ВНЕШНЕГО ИСПОЛЬЗОВАНИЯ === ##
func get_car_info() -> Dictionary:
    return {
        "name": car_name,
        "description": car_description,
        "price": price,
        "currency": currency,
        "speed": "%d км/ч" % [max_speed * 3.6],
        "grip": "%.1f/10" % [grip * 10]
    }

func upgrade(part: String):
    if _upgrades.has(part):
        _upgrades[part] += 1
        _apply_car_settings()
