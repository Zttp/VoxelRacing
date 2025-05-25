extends CanvasLayer

@onready var total_bananas_label: Label = $TotalBananasLabel
@onready var collected_bananas_label: Label = $CollectedBananasLabel

var session_bananas: int = 0  # Бананы, собранные в текущей сессии

func _ready():
    # Инициализация при старте
    update_total_bananas()
    update_collected_bananas()
    
    # Подключаем сигналы
    GameState.bananas_changed.connect(update_total_bananas)

func update_total_bananas():
    """Обновляет отображение общих сохранённых бананов"""
    total_bananas_label.text = "Всего: %d🍌" % GameState.bananas

func update_collected_bananas():
    """Обновляет отображение бананов, собранных в уровне"""
    collected_bananas_label.text = "Собрано: %d🍌" % session_bananas

func add_bananas(amount: int):
    """Добавляет временные бананы (для уровня)"""
    session_bananas += amount
    update_collected_bananas()

func save_session_bananas():
    """Переносит собранные бананы в GameState"""
    GameState.add_bananas(session_bananas)
    session_bananas = 0
    update_collected_bananas()

func _on_finish_zone_entered():
    """Пример: сохраняем бананы при завершении уровня"""
    save_session_bananas()
