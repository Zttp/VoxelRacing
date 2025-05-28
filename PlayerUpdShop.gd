func _input(event):  
    if event.is_action_pressed("interact"):  
        var shop = get_nearby_shop()  
        if shop:  
            shop.interact()  
