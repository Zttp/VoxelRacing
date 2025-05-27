extends RigidBody3D

@export var loot_table: Array[Dictionary] = [
    {"item": "fuel", "chance": 0.4},
    {"item": "food", "chance": 0.3},
    {"item": "tools", "chance": 0.2},
    {"item": "blueprint", "chance": 0.1}
]

var is_opened := false

func _on_interact_area_body_entered(body):
    if body.is_in_group("player") and !is_opened:
        $InteractionArea/Label3D.visible = true

func _on_interact_area_body_exited(body):
    if body.is_in_group("player"):
        $InteractionArea/Label3D.visible = false

func _on_interact():
    if !is_opened:
        is_opened = true
        $AnimationPlayer.play("open")
        await $AnimationPlayer.animation_finished
        spawn_loot()
        queue_free()

func spawn_loot():
    var random_item = _get_random_item()
    var loot_scene = load("res://items/" + random_item + ".tscn")
    var loot = loot_scene.instantiate()
    loot.position = global_position + Vector3(0, 0.5, 0)
    get_parent().add_child(loot)
    $OpenParticles.emitting = true
    $SoundEffect.play()

func _get_random_item() -> String:
    var roll = randf()
    var cumulative = 0.0
    
    for entry in loot_table:
        cumulative += entry["chance"]
        if roll <= cumulative:
            return entry["item"]
    
    return "fuel"  # Дефолтный предмет
