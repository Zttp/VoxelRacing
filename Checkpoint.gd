extends Area3D

@export var checkpoint_id: String = "first_checkpoint"

func _on_body_entered(body):
    if body.is_in_group("player"):
        $BeepSound.play()
        body.reached_checkpoint(checkpoint_id)
