extends CharacterBody3D

# Настройки движения
@export var walk_speed := 5.0
@export var run_speed := 8.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.002

# Состояния игрока
enum PlayerState { ON_FOOT, IN_VEHICLE, BUILDING }
var current_state = PlayerState.ON_FOOT
var current_vehicle : VehicleBody3D = null

# Физические параметры
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_speed = walk_speed
var is_running = false

# Компоненты
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var interaction_ray = $CameraPivot/Camera3D/InteractionRay
@onready var animation_player = $AnimationPlayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_player.play("idle")

func _input(event):
	# Управление камерой
	if event is InputEventMouseMotion and current_state != PlayerState.IN_VEHICLE:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -1.5, 1.5)
	
	# Взаимодействия
	if event.is_action_pressed("interact"):
		_try_interact()
	
	if event.is_action_pressed("toggle_run"):
		is_running = !is_running
		current_speed = run_speed if is_running else walk_speed

func _physics_process(delta):
	match current_state:
		PlayerState.ON_FOOT:
			_handle_foot_movement(delta)
		PlayerState.IN_VEHICLE:
			_handle_vehicle_control()
		PlayerState.BUILDING:
			_handle_building_mode()

func _handle_foot_movement(delta):
	# Гравитация
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Прыжок
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		animation_player.play("jump")

	# Движение
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		animation_player.play("run" if is_running else "walk")
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		animation_player.play("idle")

	move_and_slide()

func _handle_vehicle_control():
	if Input.is_action_just_pressed("exit_vehicle"):
		exit_vehicle()

func _handle_building_mode():
	# Логика режима строительства
	pass

func _try_interact():
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		
		if collider.is_in_group("vehicle"):
			enter_vehicle(collider)
		elif collider.is_in_group("loot_box"):
			collider.interact()
		elif collider.is_in_group("npc"):
			collider.start_dialogue()

func enter_vehicle(vehicle: VehicleBody3D):
	current_state = PlayerState.IN_VEHICLE
	current_vehicle = vehicle
	hide()
	
	# Передаем управление транспортному средству
	vehicle.set_driver(self)
	camera.current = false
	vehicle.get_node("Camera").current = true

func exit_vehicle():
	if current_vehicle:
		current_state = PlayerState.ON_FOOT
		global_transform = current_vehicle.get_node("ExitPosition").global_transform
		show()
		
		# Возвращаем управление игроку
		current_vehicle.clear_driver()
		current_vehicle = null
		camera.current = true

func toggle_building_mode(enable: bool):
	current_state = PlayerState.BUILDING if enable else PlayerState.ON_FOOT
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if enable else Input.MOUSE_MODE_CAPTURED)

# Дополнительные системы
func take_damage(amount):
	# Логика получения урона
	pass

func heal(amount):
	# Логика лечения
	pass

func add_to_inventory(item):
	# Логика добавления предмета в инвентарь
	pass
