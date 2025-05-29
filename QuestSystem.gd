extends Node

var active_quests: Array = []
var completed_quests: Array = []

signal quest_accepted(quest_data)
signal quest_completed(quest_data)

func _ready():
    load_sample_quests()

func load_sample_quests():
    var starting_quest = {
        "id": "deliver_fuel",
        "title": "Доставка топлива",
        "description": "Привези 3 канистры топлива на заправку",
        "required_item": "fuel",
        "required_quantity": 3,
        "reward_money": 500,
        "reward_items": ["toolkit"],
        "target_location": "gas_station"
    }
    add_quest(starting_quest)

func add_quest(quest_data: Dictionary):
    quest_data["progress"] = 0
    active_quests.append(quest_data)
    emit_signal("quest_accepted", quest_data)

func update_quest_progress(item_name: String, quantity: int = 1):
    for quest in active_quests:
        if quest["required_item"] == item_name:
            quest["progress"] += quantity
            if quest["progress"] >= quest["required_quantity"]:
                complete_quest(quest["id"])

func complete_quest(quest_id: String):
    var quest = get_quest_by_id(quest_id)
    Global.player_money += quest["reward_money"]
    for item in quest["reward_items"]:
        Global.add_to_inventory(item)
    completed_quests.append(quest)
    active_quests.erase(quest)
    emit_signal("quest_completed", quest)
