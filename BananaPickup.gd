extends Area3D

@export var banana_value: int = 10
@onready var sound = $AudioStreamPlayer3D

func _on_body_entered(body):
    if body.is_in_group("player"):
        GameState.add_bananas(banana_value)
        sound.play()
        # Деактивируем визуал, но оставляем звук
        $MeshInstance3D.visible = false
        await sound.finished
        queue_free()
