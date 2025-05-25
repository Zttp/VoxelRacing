extends Node

signal mission_completed(mission_id)

var active_missions = {
    "first_ride": {
        "goal": "reach_finish",
        "reward_bananas": 200,
        "completed": false
    },
    "banana_collector": {
        "goal": "collect_bananas",
        "target": 15,
        "reward_bananas": 500,
        "completed": false
    }
}

func start_mission(mission_id: String):
    if active_missions.has(mission_id):
        print("Миссия начата: ", mission_id)

func complete_mission(mission_id: String):
    if active_missions.has(mission_id) and not active_missions[mission_id]["completed"]:
        active_missions[mission_id]["completed"] = true
        var reward = active_missions[mission_id]["reward_bananas"]
        GameState.add_bananas(reward)
        emit_signal("mission_completed", mission_id)
        print("Миссия выполнена! Награда: ", reward, "🍌")
