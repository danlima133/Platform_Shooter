extends CanvasLayer

func _on_buttons_click_button(id):
	match id:
		"button_play":
			ManagerScenes.go_to_level("level_easy")
		"button_settings":
			pass
		"button_exit":
			get_tree().quit()
