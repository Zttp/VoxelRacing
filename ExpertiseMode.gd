extends Node3D

var current_car: VehicleBody3D
var is_test_active: bool = false
var start_time: float
var total_score: int = 0

# Настройки оценки
const MAX_TIME = 120.0  # Секунд
const SPEED_MULTIPLIER = 50
const STYLE_MULTIPLIER = 100

func _ready():
    spawn_random_car()
    start_test()

func spawn_random_car():
    var cars = GameState.get_unlocked_cars()  # Массив имён машин из сохранений
    var random_car = cars[randi() % cars.size()]
    var car_scene = load("res://cars/%s.tscn" % random_car)
    current_car = car_scene.instantiate()
    CarSpawnPoint.add_child(current_car)
    
    # Настройка камеры
    $CameraRig.spring_arm_length = current_car.mass * 0.5
    $CameraRig.spring_arm_top_level = true

func start_test():
    is_test_active = true
    start_time = Time.get_ticks_msec()
    $UI/CommentaryLabel.text = get_random_comment("start")
    $UI/TimerLabel.visible = true

func _process(delta):
    if is_test_active:
        update_timer()
        calculate_scores()

func update_timer():
    var elapsed = (Time.get_ticks_msec() - start_time) / 1000.0
    $UI/TimerLabel.text = "Время: %.1f" % elapsed
    
    if elapsed >= MAX_TIME:
        end_test("time_up")

func calculate_scores():
    # Очки за скорость
    var speed_score = int(current_car.linear_velocity.length() * SPEED_MULTIPLIER)
    
    # Очки за стиль (дрифт, прыжки)
    var style_score = 0
    if current_car.is_drifting():  # Метод из скрипта машины
        style_score += 10 * delta
    
    total_score = speed_score + style_score
    update_ui_scores(speed_score, style_score)

func update_ui_scores(speed: int, style: int):
    $UI/ScorePanel/SpeedScore.text = "Скорость: %d" % speed
    $UI/ScorePanel/StyleScore.text = "Стиль: %d" % style
    $UI/ScorePanel/TotalScore.text = "Всего: %d" % total_score

func end_test(reason: String):
    is_test_active = false
    $UI/TimerLabel.visible = false
    
    var final_comment = ""
    match reason:
        "time_up":
            final_comment = get_random_comment("fail_time")
        "crashed":
            final_comment = get_random_comment("fail_crash")
    
    $UI/CommentaryLabel.text = final_comment
    award_bananas(total_score)
    show_results_menu()

func get_random_comment(type: String) -> String:
    var comments = {
        "start": [
            "Посмотрим, что эта коробка может...",
            "Это не машина — это трагедия!"
        ],
        "fail_time": [
            "Даже улитка быстрее!",
            "Ты ездишь как мой дед!"
        ]
    }
    return comments[type][randi() % comments[type].size()]

func award_bananas(score: int):
    var bananas = score / 10
    GameState.add_bananas(bananas)
    $UI/CommentaryLabel.text += "\n+%d🍌" % bananas
