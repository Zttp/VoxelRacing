extends VehicleBody3D

@export var max_fuel = 100.0
var current_fuel = max_fuel

func refuel(amount: float):
    current_fuel = min(current_fuel + amount, max_fuel)
    print("Заправлено! Текущий уровень: ", current_fuel)
    
    # Визуальные эффекты
    $RefuelParticles.emitting = true
    $RefuelSound.play()
