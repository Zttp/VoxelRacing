# В скрипте игрока (player.gd)
func _input(event):
    if event.is_action_pressed("use_fuel") and inventory.has_item("fuel"):
        if current_vehicle.fuel < current_vehicle.max_fuel:
            inventory.remove_item("fuel")
            current_vehicle.fuel += 20.0  # +20% к топливу
            print("Заправлено! Топливо: ", current_vehicle.fuel)
