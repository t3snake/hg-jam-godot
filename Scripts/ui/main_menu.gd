extends CanvasLayer


func _on_play_button_pressed() -> void:
	# TODO go to hub and select task
	GlobalState.go_to_level(GlobalState.SideScrollLevel)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
