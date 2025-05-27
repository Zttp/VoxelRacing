extends CharacterBody3D

var is_near_vehicle = false
var current_vehicle = null
@onready var inventory = $Inventory  # Предполагаем, что инвентарь - дочерний нод

func _physics_process(delta):
    # Проверка близости к машине
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(
        global_position,
        global_position + transform.basis.z * -2.0,  # Проверяем перед игроком
        0b1  # Маска для слоя 1
    )
    var result = space_state.intersect_ray(query)
    
    is_near_vehicle = result and result.collider.is_in_group("vehicle")
    current_vehicle = result.collider if is_near_vehicle else null

func _input(event):
    if event.is_action_pressed("interact") and is_near_vehicle:
        try_refuel()

func try_refuel():
    if not current_vehicle:
        return
        
    # Проверяем наличие топлива в инвентаре (корректная версия)
    for i in range(inventory.items.size()):
        if inventory.items[i].name == "fuel":
            inventory.remove_item(i)  # Удаляем топливо
            current_vehicle.refuel(20.0)  # Добавляем 20% топлива
            print("Успешная заправка! Осталось топлива: ", inventory.get_item_count("fuel"))
            return
    
    print("Нет топлива в инвентаре!")
