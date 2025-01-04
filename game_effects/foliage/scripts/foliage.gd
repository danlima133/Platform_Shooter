extends CPUParticles2D

func enable_effect():
	emitting = true

func diasable_effect():
	emitting = false

func _on_foliage_area_screen_entered():
	enable_effect()

func _on_foliage_area_screen_exited():
	diasable_effect()
