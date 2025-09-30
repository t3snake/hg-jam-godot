extends CanvasLayer


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var current_level = GlobalState.current_level
	%Score.text = "Score: %d" % GlobalState.timer
	GlobalState.set_level_cleared()
	
	var high_score = GlobalState.highscore_map[current_level]
	%BestScore.text = "Best Score: %d" % high_score
	
	# Target reached checkbox logic
	#var bonus_time = GlobalState.bonus_time_map[current_level - 1]
	#%TargetTime.text = "Bonus Target Time: %.2f s" % bonus_time
	#if GlobalState.timer <= bonus_time:
		#%CheckedIcon.show()
	#else:
		#%CheckedIcon.hide()

func _on_next_level_button_pressed() -> void:
	GlobalState.go_to_level(GlobalState.LevelSelectHub3D)

func _on_restart_button_pressed() -> void:
	GlobalState.go_to_level(GlobalState.current_level)

func _on_main_menu_button_pressed() -> void:
	GlobalState.go_to_level(GlobalState.MainMenu)
