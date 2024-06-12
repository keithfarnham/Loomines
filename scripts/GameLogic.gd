extends Node2D
class_name GameLogic

@onready var clearingLine = $ClearingLine as ClearingLine
@onready var activePiece = $ActivePiece as ActivePiece
@onready var boardData = $Board as BoardData
@onready var audio_bgm = $BGM as AudioStreamPlayer
@onready var backgroundTexture = $Board/BackgroundTexture as TextureRect
@onready var gameOverText = $UI/GameOverText as RichTextLabel
@onready var youWinText = $UI/YouWinText as RichTextLabel
@onready var retryButton = $UI/RetryButton as Button
@onready var quitButton = $UI/QuitToFrontEnd as Button
#@onready var debugFPSCounter = $Debug/DebugFPSCounter

#var debugPausePos = 0

var failed := false
var win := false
var activeBlock : ActivePiece
var level := 1

func on_clearing_line_reset():
	print("Clear Line Resetting")
	
func on_fail_top_out():
	failed = true
	gameOverText.visible = true
	retryButton.visible = true
	audio_bgm.stream = load("res://audio/bmmbopdowop_fail.wav")
	audio_bgm.play()
	print("game over")
	
func on_level_change():
	if(BoardData.currentLevel > BoardData.Levels.size()):
		win = true
		youWinText.visible = true
		retryButton.visible = true
		return
	backgroundTexture.texture = load(LevelData.BackgroundTexture[BoardData.currentLevel])
	audio_bgm.stream = load(LevelData.Song[BoardData.currentLevel])
	audio_bgm.play()
	
func setup_active_block():
	for i in boardData.BLOCK_CELL_COUNT:
		activePiece.create_block()

func new_game():
	activePiece.create_block()
	audio_bgm.stream = load(LevelData.Song[BoardData.Levels.LEVEL_01])
	audio_bgm.play()
	clearingLine.on_song_start()
	backgroundTexture.texture = load(LevelData.BackgroundTexture[BoardData.currentLevel])

func _ready():
	new_game()
	BoardData.on_level_change.connect(on_level_change)
	clearingLine.on_reset.connect(on_clearing_line_reset)
	activePiece.fail_top_out.connect(on_fail_top_out)

func _process(delta):
	if quitButton.button_pressed:
		get_tree().change_scene_to_file("res://scenes/FrontEnd.tscn")
		return
	if failed or win:
		if retryButton.button_pressed:
			BoardData.currentLevel = 1
			BoardData._ready()
			get_tree().reload_current_scene()
			return
		if activePiece.is_processing():
			activePiece.set_process(false)
		if clearingLine.is_processing():
			clearingLine.set_process(false)
		return
	#debugFPSCounter.text = str(Engine.get_frames_per_second())
	
	#if clearingLine.debugPause.button_pressed and debugPausePos == 0:
		#debugPausePos = audio_bgm.get_playback_position()
		#audio_bgm.stop()
	#elif (not clearingLine.debugPause.button_pressed) and debugPausePos != 0:
		#audio_bgm.play(debugPausePos)
		#debugPausePos = 0
