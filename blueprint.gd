extends StaticBody3D

@export var blueprint_name := "engine_upgrade"

func _on_interaction_area_body_entered(body):
    if body.is_in_group("player"):
        body.inventory.add_blueprint(blueprint_name)
        $FloatingAnimation.play("pickup")
        await $FloatingAnimation.animation_finished
        queue_free()
