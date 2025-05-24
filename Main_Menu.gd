extends Node2D

# Загружаем префабы машин
const CAR_SCENES = {
    "bananamobile": preload("res://cars/bananamobile.tscn"),
    "tractor": preload("res://cars/tractor.tscn"),
    "sport": preload("res://cars/sport.tscn")
}

# Настройки машин
const CAR_DATA = {
    "bananamobile": {
        "price": 1000,
        "speed": "120 км/ч",
        "grip": "Низкий",
        "description": "Работает на банановом топливе. Склонен к заносам."
    },
    "tractor": {
        "price": 2500,
        "speed": "60 км/ч",
        "grip": "Высокий",
        "description": "Медленный, но проедет везде. Почти."
    },
    "sport": {
        "price": 5000,
        "speed": "220 км/ч",
        "grip": "Средний",
        "description": "Быстрый, но развалится от одного удара."
    }
}

# Музыка
const MUSIC_TRACKS = [
    preload("res://audio/menu_track1.ogg"),
    preload("res://audio/menu_track2.ogg"),
    preload("res://audio/menu_track3.ogg")
]

# Переменные
var current_car: String = "bananamobile"
var bananas: int = 0
var unlocked_cars: Array = ["bananamobile"]
var is_rotating_car: bool = false
var last_mouse_pos: Vector2
var current_track_index: int = 0
var ui_elements = []

func _ready():
    # Инициализация
    ui_elements = [
        $BananaCounter,
        $MenuTabs,
        $MenuTabs/Garage,
        $MenuTabs/Shop,
        $MenuTabs/Missions,
        $MenuTabs/Settings
    ]
    
    # Настройка сцены
    load_game()
    init_audio()
    update_banana_counter()
    spawn_car(current_car)
    setup_shop()
    setup_missions()
    
    # Плавное появление UI
    show_ui_animated()

func _process(delta):
    if is_rotating_car:
        rotate_car_with_mouse()

# === 🎵 Аудио ===
func init_audio():
    $MenuMusic.stream = MUSIC_TRACKS[current_track_index]
    $MenuMusic.play()
    
    # Настройка громкости из сохранений
    var volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
    $MenuTabs/Settings/VolumeSlider.value = db_to_linear(volume)

func _on_MenuMusic_finished():
    # Циклическое воспроизведение треков
    current_track_index = (current_track_index + 1) % MUSIC_TRACKS.size()
    $MenuMusic.stream = MUSIC_TRACKS[current_track_index]
    $MenuMusic.play()

# === 🚗 Система автомобилей ===
func spawn_car(car_name: String):
    # Удаляем старую машину
    for child in $CarDisplay/CarSpawnPoint.get_children():
        child.queue_free()
    
    # Создаём новую
    var car_scene = CAR_SCENES[car_name]
    var car_instance = car_scene.instantiate()
    $CarDisplay/CarSpawnPoint.add_child(car_instance)
    
    # Обновляем информацию
    update_car_info(car_name)

func update_car_info(car_name: String):
    var info = CAR_DATA[car_name]
    $MenuTabs/Garage/CurrentCarInfo.text = """
    {name}
    Скорость: {speed}
    Сцепление: {grip}
    Описание: {desc}
    """.format({
        "name": car_name.capitalize(),
        "speed": info["speed"],
        "grip": info["grip"],
        "desc": info["description"]
    })

func rotate_car_with_mouse():
    var current_pos = get_viewport().get_mouse_position()
    var delta = current_pos.x - last_mouse_pos.x
    $CarDisplay/CarSpawnPoint.rotate_y(-delta * 0.01)
    last_mouse_pos = current_pos

func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            is_rotating_car = event.pressed
            if event.pressed:
                last_mouse_pos = get_viewport().get_mouse_position()

# === 🍌 Банановая система ===
func update_banana_counter():
    $BananaCounter.text = "🍌: %d" % bananas

func add_bananas(amount: int):
    bananas += amount
    update_banana_counter()
    save_game()

# === 🛒 Магазин ===
func setup_shop():
    $MenuTabs/Shop/CarList.clear()
    for car_name in CAR_DATA.keys():
        var price = CAR_DATA[car_name]["price"]
        var owned = "[В гараже]" if car_name in unlocked_cars else "[%d🍌]" % price
        $MenuTabs/Shop/CarList.add_item("%s %s" % [car_name.capitalize(), owned])

func _on_CarList_item_selected(index):
    var car_name = CAR_DATA.keys()[index]
    var info = CAR_DATA[car_name]
    $MenuTabs/Shop/ShopCarInfo.text = """
    {name}
    Цена: {price}🍌
    {desc}
    """.format({
        "name": car_name.capitalize(),
        "price": info["price"],
        "desc": info["description"]
    })
    
    spawn_car(car_name)
    $MenuTabs/Shop/PreviewText.text = "Предпросмотр: " + car_name.capitalize()

func _on_BuyButton_pressed():
    var selected = $MenuTabs/Shop/CarList.get_selected_items()
    if selected.size() > 0:
        var car_name = CAR_DATA.keys()[selected[0]]
        var price = CAR_DATA[car_name]["price"]
        
        if car_name in unlocked_cars:
            $MenuTabs/Shop/ShopCarInfo.text = "Уже куплено!"
        elif bananas >= price:
            bananas -= price
            unlocked_cars.append(car_name)
            update_banana_counter()
            setup_shop()
            $MenuTabs/Shop/ShopCarInfo.text = "Куплено!"
            save_game()
        else:
            $MenuTabs/Shop/ShopCarInfo.text = "Не хватает бананов!"

# === 📜 Миссии ===
func setup_missions():
    var missions = [
        {"name": "Банановый сбор", "reward": 500, "desc": "Собери 50 бананов за поездку"},
        {"name": "Дрифт-мастер", "reward": 800, "desc": "Сделай 3 полных заноса"},
        {"name": "Гонка с фермером", "reward": 1200, "desc": "Обгони трактор"}
    ]
    
    $MenuTabs/Missions/MissionList.clear()
    for mission in missions:
        $MenuTabs/Missions/MissionList.add_item("%s (+%d🍌)" % [mission["name"], mission["reward"]])

func _on_MissionList_item_selected(index):
    var missions = [
        {"name": "Банановый сбор", "reward": 500, "desc": "Собери 50 бананов за поездку"},
        {"name": "Дрифт-мастер", "reward": 800, "desc": "Сделай 3 полных заноса"},
        {"name": "Гонка с фермером", "reward": 1200, "desc": "Обгони трактор"}
    ]
    $MenuTabs/Missions/MissionDescription.text = missions[index]["desc"]

# === ⚙️ Настройки ===
func _on_VolumeSlider_value_changed(value):
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
    save_game()

func _on_FullscreenCheck_toggled(button_pressed):
    if button_pressed:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    save_game()

# === 💾 Сохранение ===
func save_game():
    var save_data = {
        "bananas": bananas,
        "unlocked_cars": unlocked_cars,
        "current_car": current_car,
        "volume": $MenuTabs/Settings/VolumeSlider.value,
        "fullscreen": $MenuTabs/Settings/FullscreenCheck.button_pressed
    }
    var file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))

func load_game():
    if FileAccess.file_exists("user://savegame.dat"):
        var file = FileAccess.open("user://savegame.dat", FileAccess.READ)
        var data = JSON.parse_string(file.get_as_text())
        bananas = data["bananas"]
        unlocked_cars = data["unlocked_cars"]
        current_car = data["current_car"]
        $MenuTabs/Settings/VolumeSlider.value = data.get("volume", 0.5)
        $MenuTabs/Settings/FullscreenCheck.button_pressed = data.get("fullscreen", false)

# === 🎨 UI Анимации ===
func show_ui_animated():
    for element in ui_elements:
        element.modulate.a = 0
        element.visible = true
        create_tween().tween_property(element, "modulate:a", 1.0, 0.5)

func hide_ui_animated():
    var tweens = []
    for element in ui_elements:
        var tween = create_tween()
        tween.tween_property(element, "modulate:a", 0.0, 0.3)
        tweens.append(tween)
    
    await get_tree().create_timer(0.3).timeout
    for element in ui_elements:
        element.visible = false

# === 🎮 Переходы ===
func _on_StartGame_pressed():
    await hide_ui_animated()
    get_tree().change_scene_to_file("res://game_world.tscn")

func _on_ExitGame_pressed():
    await hide_ui_animated()
    get_tree().quit()
