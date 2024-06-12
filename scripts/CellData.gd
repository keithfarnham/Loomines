extends Node

class_name CellData

var textures = load("res://art/lumines_tiles.png")

enum CellColor {EMPTY = 0, COLOR_1 = 2, COLOR_2 = 3}
enum CellState {NONE = 0, TO_FALL = 1, FALLING = 2, MATCHED = 3, CLEARING = 4}
var color := CellColor.EMPTY
var state := CellState.NONE
var sprite : Sprite2D
var numCellsToFall : int
var matchingShape : Vector2i
var clearLineTouched = false
var matchingDir = []

func _init(cellColor = CellColor.EMPTY ):
	color = cellColor
	sprite = Sprite2D.new()
	matchingShape = Vector2i(-1, -1)
