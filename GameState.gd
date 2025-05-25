extends Node

# Состояние игры
signal bananas_changed(new_amount)
signal mission_completed(mission_id)
signal car_unlocked(car_name)

# Игровые данные
var bananas: int = 0:
    set(value):
        bananas = value
        bananas_changed.emit(bananas)
        save_game()

var unlocked_cars: Array = ["bananamobile"]  # Стартовая машина
var current_car: String = "bananamobile"
var completed_missions: Array = []

# Настройки
var save_path: String = "user://savegame.dat"

func _ready():
    load_game()

# === Экономика ===
func add_bananas(amount: int):
    bananas += amount

func spend_bananas(amount: int) -> bool:
    if bananas >= amount:
        bananas -= amount
        return true
    return false

# === Машины ===
func unlock_car(car_name: String):
    if not car_name in unlocked_cars:
        unlocked_cars.append(car_name)
        car_unlocked.emit(car_name)
        save_game()

func set_current_car(car_name: String):
    if car_name in unlocked_cars:
        current_car = car_name
        save_game()

# === Миссии ===
func complete_mission(mission_id: String):
    if not mission_id in completed_missions:
        completed_missions.append(mission_id)
        mission_completed.emit(mission_id)
        save_game()

func is_mission_completed(mission_id: String) -> bool:
    return mission_id in completed_missions

# === Сохранение ===
func save_game():
    var save_data = {
        "bananas": bananas,
        "unlocked_cars": unlocked_cars,
        "current_car": current_car,
        "completed_missions": completed_missions
    }
    
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))

func load_game():
    if not FileAccess.file_exists(save_path):
        return
    
    var file = FileAccess.open(save_path, FileAccess.READ)
    var data = JSON.parse_string(file.get_as_string())
    
    if data:
        bananas = data.get("bananas", 0)
        unlocked_cars = data.get("unlocked_cars", ["bananamobile"])
        current_car = data.get("current_car", "bananamobile")
        completed_missions = data.get("completed_missions", [])
