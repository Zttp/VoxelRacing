extends Node

# ███████╗███████╗███████╗
# ██╔════╝██╔════╝██╔════╝
# █████╗  ███████╗███████╗
# ██╔══╝  ╚════██║╚════██║
# ███████╗███████║███████║
# ╚══════╝╚══════╝╚══════╝

# ========================
# 1. Основные параметры игры
# ========================
var player_money: int = 1000 setget _set_player_money
var game_days: int = 1
var current_time: float = 8.0  # Время в часах (8:00 утра)

# ========================
# 2. Инвентарь и ресурсы
# ========================
var player_inventory: Array = []  # Формат: [{"name": String, "quantity": int}]
var fuel_price_multiplier: float = 1.0  # Модификатор цен на топливо

# ========================
# 3. Сигналы
# ========================
signal money_changed(amount: int)
signal inventory_updated
signal day_passed
signal time_changed(hour: float)

# ========================
# 4. Настройки сложности
# ========================
var difficulty: String = "medium" setget _set_difficulty
var fuel_consumption_rate: float = 0.1  # Базовый расход топлива

# ========================
# 5. Прогресс игры
# ========================
var unlocked_locations: Array = ["starting_city"]
var completed_quests: Array = []

# ========================
# МЕТОДЫ
# ========================

func _ready():
	randomize()
	_load_game()

# ========================
# Деньги
# ========================
func add_money(amount: int) -> void:
	player_money += amount
	emit_signal("money_changed", player_money)
	_save_game()

func spend_money(amount: int) -> bool:
	if player_money >= amount:
		player_money -= amount
		emit_signal("money_changed", player_money)
		_save_game()
		return true
	return false

func _set_player_money(value: int) -> void:
	player_money = max(0, value)
	emit_signal("money_changed", player_money)
	_save_game()

# ========================
# Инвентарь
# ========================
func add_to_inventory(item_name: String, quantity: int = 1) -> void:
	for item in player_inventory:
		if item["name"] == item_name:
			item["quantity"] += quantity
			emit_signal("inventory_updated")
			_save_game()
			return
	
	player_inventory.append({"name": item_name, "quantity": quantity})
	emit_signal("inventory_updated")
	_save_game()

func remove_from_inventory(item_name: String, quantity: int = 1) -> bool:
	for i in range(player_inventory.size()):
		if player_inventory[i]["name"] == item_name:
			if player_inventory[i]["quantity"] >= quantity:
				player_inventory[i]["quantity"] -= quantity
				
				if player_inventory[i]["quantity"] <= 0:
					player_inventory.remove_at(i)
				
				emit_signal("inventory_updated")
				_save_game()
				return true
			break
	return false

func has_item(item_name: String) -> bool:
	for item in player_inventory:
		if item["name"] == item_name and item["quantity"] > 0:
			return true
	return false

func get_item_quantity(item_name: String) -> int:
	for item in player_inventory:
		if item["name"] == item_name:
			return item["quantity"]
	return 0

# ========================
# Время и дни
# ========================
func advance_time(hours: float) -> void:
	current_time += hours
	
	# Проверка на смену дня
	if current_time >= 24.0:
		current_time = fmod(current_time, 24.0)
		game_days += 1
		emit_signal("day_passed")
		_update_economy()
	
	emit_signal("time_changed", current_time)
	_save_game()

func _update_economy() -> void:
	# Динамическое изменение цен
	fuel_price_multiplier = 1.0 + randf() * 0.3  # ±30%
	
	# Обновляем только если есть сохранение
	if FileAccess.file_exists("user://save.dat"):
		_save_game()

# ========================
# Сложность
# ========================
func _set_difficulty(value: String) -> void:
	difficulty = value
	match difficulty:
		"easy":
			fuel_consumption_rate = 0.07
		"medium":
			fuel_consumption_rate = 0.1
		"hard":
			fuel_consumption_rate = 0.15
	_save_game()

# ========================
# Сохранение/загрузка
# ========================
func _save_game() -> void:
	var save_data = {
		"money": player_money,
		"inventory": player_inventory,
		"days": game_days,
		"time": current_time,
		"locations": unlocked_locations,
		"quests": completed_quests,
		"difficulty": difficulty
	}
	
	var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
	file.store_var(save_data)
	file.close()

func _load_game() -> void:
	if not FileAccess.file_exists("user://save.dat"):
		return
	
	var file = FileAccess.open("user://save.dat", FileAccess.READ)
	var save_data = file.get_var()
	file.close()
	
	player_money = save_data.get("money", 1000)
	player_inventory = save_data.get("inventory", [])
	game_days = save_data.get("days", 1)
	current_time = save_data.get("time", 8.0)
	unlocked_locations = save_data.get("locations", ["starting_city"])
	completed_quests = save_data.get("quests", [])
	difficulty = save_data.get("difficulty", "medium")
	
	emit_signal("money_changed", player_money)
	emit_signal("inventory_updated")
	emit_signal("time_changed", current_time)

func reset_game() -> void:
	player_money = 1000
	player_inventory = []
	game_days = 1
	current_time = 8.0
	unlocked_locations = ["starting_city"]
	completed_quests = []
	difficulty = "medium"
	
	_save_game()
	emit_signal("money_changed", player_money)
	emit_signal("inventory_updated")
	emit_signal("time_changed", current_time)

# ========================
# Утилиты
# ========================
func format_time() -> String:
	var hours = int(current_time)
	var minutes = int((current_time - hours) * 60)
	return "%02d:%02d" % [hours, minutes]

func get_current_biome() -> String:
	# Здесь должна быть логика определения биома
	return "forest" if randf() > 0.5 else "city"
