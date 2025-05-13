extends ColorRect

func _on_controls_timer_timeout():
	visible = false
	queue_free()
