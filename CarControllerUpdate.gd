# Добавь в самое начало:
var bananas_collected: int = 0

# Новый метод:
func add_bananas(amount: int):
    bananas_collected += amount
    $HUD/banana_counter.text = "🍌: %d" % bananas_collected
    
    # Проверка миссий
    if MissionManager.active_missions["banana_collector"]["target"] <= bananas_collected:
        MissionManager.complete_mission("banana_collector")
