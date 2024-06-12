extends Line2D

class_name ClearingLine

#coords * tilemap size of 64
const TOP_LEFT_COORD := Vector2i(1, 3) * 64
const BOTTOM_LEFT_COORD := Vector2i(1, 13) * 64
const TOP_RIGHT_COORD := Vector2i(17, 3) * 64
const BOTTOM_RIGHT_COORD := Vector2i(17, 13) * 64

var syncTime = 0.0
#var debugNumBeats = 0
var lineXPos = 0

var bpm = 160.0
var speedModifier = LevelData.SpeedMod[BoardData.currentLevel]

@onready var debugPause = $"../Debug/DebugPauseClearLine"

#@onready var debugCellX = $"../Debug/DebugClearingLineCellX"
#@onready var debugSpeed = $"../Debug/DebugDisplay"
#@onready var debugLineSpeedMod = $"../Debug/DebugLineSpeedMod" as HSlider
@onready var audio_bgm = $"../BGM"

signal on_reset

func get_clear_cell():
	return int(points[0].x / 64) - 1

func get_next_clear_cell():
	return int(points[0].x / 64)
	
func on_song_start():
	if BoardData.currentLevel > BoardData.Levels.size():
		return 
	bpm = LevelData.BPM[BoardData.currentLevel]
	speedModifier = LevelData.SpeedMod[BoardData.currentLevel]
	#debugLineSpeedMod.value = speedModifier

# Called when the node enters the scene tree for the first time.
func _ready():
	add_point(TOP_LEFT_COORD)
	add_point(BOTTOM_LEFT_COORD)
	#debugLineSpeedMod.value = LevelData.SpeedMod[BoardData.currentLevel]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if debugPause.button_pressed:
		return
	#debugCellX.position = points[0]
	#debugCellX.text = str(get_clear_cell())

	var msPerBeat = 60000.0 / bpm
	var msPerMeasure = msPerBeat * 4
	var msPerPixel = msPerMeasure / BoardData.GRID_CELL_PIXEL_COUNT
	var numPixelsToMove = 0
	var currentTime = audio_bgm.get_playback_position()
	
	speedModifier = LevelData.SpeedMod[BoardData.currentLevel]#debugLineSpeedMod.value

	currentTime *= 1000 #sec to ms
	
	#debugSpeed.text = "Debug Num Measures: " + str((currentTime / msPerMeasure) as int) + "\nLevel: " + str(BoardData.currentLevel) + "\nSong  BPM: " +\
	#str(LevelData.BPM[BoardData.currentLevel]) + "\nSong Speed Mod: " + str(LevelData.SpeedMod[BoardData.currentLevel]) + \
	#"\nCurrentScore: " + str(BoardData.score) + "\nPoints To Next Level: " + str(BoardData.LEVEL_SCORE_REQ[BoardData.currentLevel] - BoardData.score)

	#get total pixel pos for song, then modulo for pixel pos on grid and add side buffer pixel count
	var newXPos = (currentTime / msPerPixel * speedModifier)
	newXPos = newXPos as int % (BoardData.GRID_WIDTH * BoardData.GRID_CELL_PIXEL_COUNT)
	newXPos += BoardData.GRID_SIDE_BUFFER * BoardData.GRID_CELL_PIXEL_COUNT
	
	if newXPos < lineXPos:
		#line is resetting
		on_reset.emit()
	
	lineXPos = newXPos
	
	#print("ClearingLine numPixelsToMove is " + str(numPixelsToMove) + " currTime = " + str(currentTime) + \
	#" xPosShouldBe = " + str(xPosShouldBe) + " points[0].x = " + str(points[0].x))
	
	numPixelsToMove = lineXPos - points[0].x
	
	#add the ms time for each pixel moved to the syncTime
	#debugNumBeats += numPixelsToMove

	points[0].x += numPixelsToMove
	points[1].x += numPixelsToMove
