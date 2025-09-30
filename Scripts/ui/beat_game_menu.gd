extends CanvasLayer


func _on_main_menu_button_pressed() -> void:
	GlobalState.go_to_level(GlobalState.MainMenu)
