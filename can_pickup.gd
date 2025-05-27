# Добавьте в Inventory.gd
func can_pickup(item_weight: float = 0.5) -> bool:
    # Проверяет, можно ли поднять предмет
    return (items.size() < max_slots) and (current_weight + item_weight <= max_weight)
