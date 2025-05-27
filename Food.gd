extends RigidBody3D

@export var hunger_restore := 15.0

func _on_bounce_area_body_entered(body):
    if body.is_in_group("player"):
        body.stats.restore_hunger(hunger_restore)
        $RotateAnimation.play("consume")
        await $RotateAnimation.animation_finished
        queue_free()
