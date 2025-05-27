extends RigidBody3D

@export var fuel_amount := 20.0

func _on_pickup_area_body_entered(body):
    if body.is_in_group("player") and body.inventory.can_pickup():
        body.inventory.add_fuel(fuel_amount)
        $SoundEffect.play()
        queue_free()
