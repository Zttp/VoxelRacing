extends Area3D

# Настройки
@export var banana_value: int = 10
@export var rotation_speed: float = 2.0
@export var float_height: float = 0.2
@export var float_speed: float = 1.5

# Системные переменные
var is_collected: bool = false
var initial_y: float
var time: float = 0

func _ready():
    # Инициализация начальной позиции для плавающей анимации
    initial_y = position.y
    # Подключаем сигнал столкновения
    body_entered.connect(_on_body_entered)

func _process(delta):
    if is_collected:
        return
    
    # Анимация вращения
    $BananaMesh.rotate_y(rotation_speed * delta)
    
    # Плавающая анимация
    time += delta
    var new_y = initial_y + sin(time * float_speed) * float_height
    position.y = new_y

func _on_body_entered(body):
    if is_collected or !body.is_in_group("player"):
        return
    
    is_collected = true
    $CollisionShape3D.disabled = true
    
    # Визуальные эффекты
    $BananaMesh.visible = false
    $Particles.emitting = true
    $AudioStreamPlayer3D.play()
    
    # Добавляем бананы в GameState
    GameState.add_bananas(banana_value)
    
    # Уничтожаем объект после завершения эффектов
    await $AudioStreamPlayer3D.finished
    queue_free()

# Функция для ручного сбора (например, через триггер)
func collect():
    if is_collected:
        return
    _on_body_entered(get_tree().get_first_node_in_group("player"))
