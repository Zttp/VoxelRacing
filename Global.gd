var player_money := 1000  # Стартовый капитал

func add_money(amount: int):  
    player_money += amount  
    money_changed.emit()  # Сигнал для обновления UI  

signal money_changed  
