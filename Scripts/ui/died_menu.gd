extends CanvasLayer


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	GlobalState.update_high_score()
	var high_score = GlobalState.highscore_map[GlobalState.current_level]
	%BestScore.text = "Best Score: %d" % high_score

func _on_restart_button_pressed() -> void:
	GlobalState.reset_state()
	GlobalState.go_to_level(GlobalState.SideScrollLevel)

func _on_main_menu_button_pressed() -> void:
	GlobalState.reset_state()
	GlobalState.go_to_level(GlobalState.MainMenu)
