func _input(event):
    if event.is_action_pressed("inventory"):
        $UI/Inventory.visible = !$UI/Inventory.visible
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if $UI/Inventory.visible else Input.MOUSE_MODE_CAPTURED)
