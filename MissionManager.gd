extends Node

var active_missions: Array = []
var completed_missions: Array = []

func start_mission(mission_id: String):
    var mission = MissionsData.get_mission(mission_id)
    active_missions.append(mission)

func update_mission_progress(mission_id: String, progress: int):
    for mission in active_missions:
        if mission.id == mission_id:
            mission.current_progress += progress
            if mission.current_progress >= mission.target:
                complete_mission(mission_id)

func complete_mission(mission_id: String):
    var mission = MissionsData.get_mission(mission_id)
    GameState.add_bananas(mission.reward)
    active_missions.erase(mission)
    completed_missions.append(mission)
    # Сохраняем прогресс
    GameState.save_game()
