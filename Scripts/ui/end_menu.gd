extends CanvasLayer


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	GlobalState.set_level_cleared()
	
	var current_level = GlobalState.current_level
	%Score.text = "Score: %d" % GlobalState.score
	
	var high_score = GlobalState.highscore_map[current_level]
	%BestScore.text = "Best Score: %d" % high_score
	
	if GlobalState.score < 4500:
		%Outcome.text = "You rated slightly below expectation."
	elif GlobalState.score < 6500:
		%Outcome.text = "You met expectations."
	else:
		%Outcome.text = "You exceeded expectations."
	
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
	GlobalState.reset_state()
	GlobalState.go_to_level(GlobalState.current_level)

func _on_main_menu_button_pressed() -> void:
	GlobalState.reset_state()
	GlobalState.go_to_level(GlobalState.MainMenu)
