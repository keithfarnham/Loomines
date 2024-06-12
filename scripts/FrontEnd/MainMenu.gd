extends Control

@onready var audio_bgm = $BGM as AudioStreamPlayer

func _ready():
	audio_bgm.play()
