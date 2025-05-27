@export var max_fuel := 100.0
@export var fuel_consumption_rate := 0.1  # Расход на 1 км
var current_fuel := max_fuel

func _physics_process(delta):
    if is_moving:
        current_fuel -= fuel_consumption_rate * speed * delta
        if current_fuel <= 0:
            engine_power = 0  # Фургон глохнет



func _process(delta):
    var fuel_percent = (current_fuel / max_fuel) * 100
    $FuelGauge.value = fuel_percent
    $FuelGauge/Label.text = "%d%%" % fuel_percent
