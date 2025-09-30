extends CanvasLayer


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var current_level = GlobalState.current_level
	var high_score = GlobalState.highscore_map[current_level]
	%BestClearTime.text = "Best Clear Time: %.2f s" % high_score

func _on_restart_button_pressed() -> void:
	GlobalState.go_to_level(GlobalState.LevelSelectHub3D)

func _on_main_menu_button_pressed() -> void:
	GlobalState.go_to_level(GlobalState.MainMenu)
