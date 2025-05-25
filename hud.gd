extends CanvasLayer

func _ready():
    update_mission_text("first_ride")

func update_mission_text(mission_id: String):
    var text = ""
    match mission_id:
        "first_ride":
            text = "Миссия: Доедь до финиша!"
        "banana_collector":
            text = "Миссия: Собери 15 бананов"
    $MissionLabel.text = text

func _on_finish_zone_body_entered(body):
    if body.is_in_group("player"):
        MissionManager.complete_mission("first_ride")
