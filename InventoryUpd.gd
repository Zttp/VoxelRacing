extends Node
class_name Inventory

var items = []  # Массив словарей: { "name": "fuel", "weight": 5.0 }

# Новая функция для проверки наличия предмета
func has_item(item_name: String) -> bool:
    for item in items:
        if item["name"] == item_name:
            return true
    return false

# Новая функция для подсчета количества
func get_item_count(item_name: String) -> int:
    var count = 0
    for item in items:
        if item["name"] == item_name:
            count += 1
    return count

func remove_item(index: int):
    items.remove_at(index)
    update_ui()
