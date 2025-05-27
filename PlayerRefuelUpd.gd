extends CharacterBody3D

var is_near_vehicle := false
var current_vehicle: Node = null
@export var interaction_distance := 2.0

func _physics_process(_delta):
    check_nearby_vehicle()

func check_nearby_vehicle():
    # Сбрасываем состояние
    is_near_vehicle = false
    current_vehicle = null
    
    # Создаем луч вперед от игрока
    var query = PhysicsRayQueryParameters3D.create(
        global_position,
        global_position - global_transform.basis.z * interaction_distance,
        0xFFFFFFFF,  # Проверяем все слои
        [self]  # Игнорируем самого себя
    )
    
    var result = get_world_3d().direct_space_state.intersect_ray(query)
    
    # Проверяем результат
    if result.is_empty():
        return
    
    # Безопасное обращение к словарю
    if result.has("collider"):
        var collider = result["collider"]
        if collider.is_in_group("vehicle"):
            is_near_vehicle = true
            current_vehicle = collider

func try_refuel():
    if not is_near_vehicle or not current_vehicle:
        print("Нет транспортного средства рядом")
        return
    
    # Получаем ссылку на инвентарь (убедитесь, что он есть в сцене)
    var inventory = get_node_or_null("Inventory")
    if not inventory:
        print("Инвентарь не найден")
        return
    
    # Проверяем наличие топлива
    for i in range(inventory.items.size()):
        var item = inventory.items[i]
        if item.name == "fuel":
            inventory.remove_item(i)
            current_vehicle.refuel(20.0)
            print("Заправлено! Топлива осталось: ", current_vehicle.fuel)
            return
    
    print("В инвентаре нет топлива")
