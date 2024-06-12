extends Button

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if button_pressed:
		get_tree().change_scene_to_file("res://scenes/MainScene.tscn")
