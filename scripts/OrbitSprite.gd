extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("animation_finished", _on_anim_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_anim_finished():
	visible = false
	queue_free()
	print("freeing orbit sprite")
