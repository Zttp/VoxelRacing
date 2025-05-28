extends StaticBody3D

@export var items_for_sale: Array[Dictionary] = [
    {"name": "fuel", "price": 100, "stock": 10},
    {"name": "tools", "price": 250, "stock": 5},
    {"name": "food", "price": 50, "stock": 20}
]

func _on_interact():  
    Global.ui.show_shop_ui(items_for_sale)  

func buy_item(item_name: String):  
    for item in items_for_sale:  
        if item["name"] == item_name and item["stock"] > 0:  
            if Global.player_money >= item["price"]:  
                Global.add_money(-item["price"])  
                item["stock"] -= 1  
                Global.player_inventory.add_item(item_name)  
                $AudioStreamPlayer3D.play()  
            else:  
                print("Недостаточно денег!")  
