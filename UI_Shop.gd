extends CanvasLayer

@onready var item_list = $Panel/ItemList  
@onready var money_label = $Panel/MoneyLabel  

func show_shop(items: Array):  
    item_list.clear()  
    for item in items:  
        item_list.add_item(f"{item['name']} - ${item['price']} (Осталось: {item['stock']})")  
    money_label.text = str(Global.player_money) + "$"  
    show()  

func _on_buy_button_pressed():  
    var selected = item_list.get_selected_items()  
    if selected.size() > 0:  
        get_parent().buy_item(items_for_sale[selected[0]]["name"])  
