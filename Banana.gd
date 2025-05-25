extends Area3D

@export var banana_value: int = 10
var is_collected: bool = false

func _on_body_entered(body):
    if not is_collected and body.is_in_group("player"):
        is_collected = true
        $BananaMesh.visible = false
        $CollectSound.play()
        
        # Передаём бананы игроку
        body.add_bananas(banana_value)
        
        # Удаляем через 1 сек (чтобы звук успел проиграться)
        await get_tree().create_timer(1.0).timeout
        queue_free()
