extends Node

var items: Array[String] = []
var max_slots := 30
var current_weight := 0.0
var max_weight := 50.0  # кг

func add_item(item_name: String) -> bool:
    if items.size() < max_slots and current_weight + get_item_weight(item_name) <= max_weight:
        items.append(item_name)
        current_weight += get_item_weight(item_name)
        update_ui()
        return true
    return false

func remove_item(item_name: String):
    if items.has(item_name):
        items.erase(item_name)
        current_weight -= get_item_weight(item_name)
        update_ui()

func get_item_weight(item: String) -> float:
    match item:
        "fuel": return 5.0
        "food": return 1.0
        "tools": return 3.0
        _: return 0.5

func update_ui():
    for i in range($GridContainer.get_child_count()):
        var slot = $GridContainer.get_child(i)
        if i < items.size():
            slot.texture_normal = load("res://icons/" + items[i] + ".png")
        else:
            slot.texture_normal = null
    $WeightBar.value = (current_weight / max_weight) * 100
