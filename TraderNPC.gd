extends NPC

@export var wanted_items: Array[String] = ["fuel", "tools"]  
@export var offered_items: Array[String] = ["food", "medkit"]  

func _on_trade():  
    if Global.player_inventory.has_any(wanted_items):  
        var item = Global.player_inventory.remove_random(wanted_items)  
        Global.player_inventory.add_item(offered_items.pick_random())  
