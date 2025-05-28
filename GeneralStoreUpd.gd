func update_prices():  
    for item in items_for_sale:  
        # Чем меньше остаток, тем выше цена  
        var demand = 1.0 + (10.0 - item["stock"]) * 0.1  
      item["price"] = int(item["base_price"] * demand)  
