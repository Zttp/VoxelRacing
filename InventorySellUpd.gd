func sell_item(item_name: String, quantity: int = 1) -> bool:
    if get_item_quantity(item_name) >= quantity:
        var price = get_item_price(item_name) * quantity
        remove_from_inventory(item_name, quantity)
        Global.add_money(price)
        QuestSystem.update_quest_progress(item_name, quantity)
        return true
    return false

func get_item_price(item_name: String) -> int:
    var prices = {
        "fuel": 80,
        "tools": 200,
        "food": 30,
        "scrap": 15
    }
    return prices.get(item_name, 0)
