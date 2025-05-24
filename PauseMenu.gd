extends CanvasLayer

@onready var menu_panel = $MenuPanel
@onready var settings_submenu = $SettingsSubmenu

func _ready():
    visible = false
    settings_submenu.visible = false

func _input(event):
    if event.is_action_pressed("pause"):
        get_tree().paused = !get_tree().paused
        visible = !visible
        
        if visible:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume_button_pressed():
    get_tree().paused = false
    visible = false
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_main_menu_button_pressed():
    get_tree().paused = false
    get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_settings_button_pressed():
    menu_panel.visible = false
    settings_submenu.visible = true

func _on_quit_button_pressed():
    get_tree().quit()

# Возврат из настроек
func _on_back_button_pressed():
    settings_submenu.visible = false
    menu_panel.visible = true
