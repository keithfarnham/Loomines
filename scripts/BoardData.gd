extends Node2D

#grid vars
const GRID_WIDTH := 16
const GRID_HEIGHT := 10
const GRID_SIDE_BUFFER := 1
const GRID_TOP_BUFFER := 3
const GRID_CELL_PIXEL_COUNT := 64

const BLOCK_START_POS := [Vector2i(8, 1), Vector2i(9, 1), Vector2i(8, 2), Vector2i(9, 2)] #block starts on grid X = 8 & 9
const DIRECTIONS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]

enum MATCH_DIR {TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT}
const MATCH_DIR_VALUES := {
	MATCH_DIR.TOP_LEFT: [Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1)], 
	MATCH_DIR.TOP_RIGHT: [Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1)], 
	MATCH_DIR.BOTTOM_RIGHT: [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)],
	MATCH_DIR.BOTTOM_LEFT: [Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)] 
}

signal on_land_cell
signal on_level_change

var currentClearingLineX
var CellGrid = []
var MatchingShapes = []

enum Levels {LEVEL_01 = 1, LEVEL_02 = 2, LEVEL_03 = 3}
var currentLevel = 1
var score = 0

const LEVEL_SCORE_REQ := {
	1: 24, 2: 48, 3: 96
}

class MatchingShapeData:
	var gridIndex : Vector2i
	var color : CellData.CellColor
	var toClear := false

var textures = load("res://art/lumines_tiles.png")
var matchOrbitScene = preload("res://scenes/MatchOrbitScene.tscn")

func debug_print_cell_grid(matchingBlockCell := Vector2i(-1, -1), clearingLineXIndex = -1):
	print_rich("[b]CellGrid print[/b]")
	var string := "   "
	for w in GRID_WIDTH:
		if w < 10:
			string += str(w) + ", "
		else:
			string += str(w) + ","
	string += "\n"
	for h in GRID_HEIGHT:
		string += str(h) + " "
		for w in GRID_WIDTH:
			var cellString = ""
			if w == clearingLineXIndex:
				cellString += "[b]|[/b]"
			else:
				cellString += " "
			var checkPos = Vector2i(w, h)
			match CellGrid[w][h].color:
				CellData.CellColor.EMPTY:
					if checkPos == matchingBlockCell:
						cellString += "[color=red]"
					cellString += "0"
					if checkPos == matchingBlockCell:
						cellString += "[color=grey]"
				CellData.CellColor.COLOR_1:
					cellString += "[color=orange]"
					if checkPos == matchingBlockCell:
						cellString += "X"
					elif CellGrid[w][h].state == CellData.CellState.MATCHED:
						cellString += "A"
						#string += str(CellGrid[w][h].matchingShape)
					elif CellGrid[w][h].state == CellData.CellState.CLEARING:
						cellString += "C"
						#string += str(CellGrid[w][h].matchingShape)
					else:
						cellString += str(CellGrid[w][h].color - 1)
					cellString += "[color=grey]"
				CellData.CellColor.COLOR_2:
					cellString += "[color=blue]"
					if checkPos == matchingBlockCell:
						cellString += "X"
					elif CellGrid[w][h].state == CellData.CellState.MATCHED:
						cellString += "a"
						#string += str(CellGrid[w][h].matchingShape)
					elif CellGrid[w][h].state == CellData.CellState.CLEARING:
						cellString += "c"
						#string += str(CellGrid[w][h].matchingShape)
					else:
						cellString += str(CellGrid[w][h].color - 1)
					cellString += "[color=grey]"
			string += cellString
			string += ","
		string += "\n"
	print_rich(string)

func grid_to_orbit_pos(gridPos):
	var pixelPos = gridPos
	pixelPos.x = (gridPos.x + GRID_SIDE_BUFFER)
	pixelPos.y = (gridPos.y + GRID_TOP_BUFFER)
	pixelPos *= GRID_CELL_PIXEL_COUNT
	#fix half cell offset
	return pixelPos

func grid_to_pixel_pos(gridPos):
	var pixelPos = gridPos
	pixelPos.x = (gridPos.x + GRID_SIDE_BUFFER)
	pixelPos.y = (gridPos.y + GRID_TOP_BUFFER)
	pixelPos *= GRID_CELL_PIXEL_COUNT
	#fix half cell offset
	pixelPos.x += 32
	pixelPos.y += 32
	return pixelPos
	
func pixel_to_grid_pos(pixelPos):
	var gridPos = pixelPos
	#account for offset fix
	gridPos.x -= 32
	gridPos.y -= 32
	gridPos /= GRID_CELL_PIXEL_COUNT
	gridPos.x -= GRID_SIDE_BUFFER
	gridPos.y -= GRID_TOP_BUFFER
	return gridPos
	
func get_cell_color_atlas_texture(atlasCellIndex : int):
	var atlasTexture = AtlasTexture.new()
	atlasTexture.atlas = textures
	atlasTexture.region = Rect2i(Vector2i(atlasCellIndex * BoardData.GRID_CELL_PIXEL_COUNT, 0) , Vector2i(BoardData.GRID_CELL_PIXEL_COUNT, BoardData.GRID_CELL_PIXEL_COUNT))
	return atlasTexture

func land_cell(gridIndex : Vector2i, color : CellData.CellColor):
	if not CellGrid[gridIndex.x][gridIndex.y].sprite:
		#if a sprite doesn't exists for this cell when landing it, make a new one
		print("[land_cell] doing sprite setup for cell " + str(gridIndex))
		CellGrid[gridIndex.x][gridIndex.y].sprite = Sprite2D.new()
	
	CellGrid[gridIndex.x][gridIndex.y].state = CellData.CellState.NONE
	CellGrid[gridIndex.x][gridIndex.y].color = color
	var atlasTexture = get_cell_color_atlas_texture(get_texture_atlas_index_for_level(color))
	CellGrid[gridIndex.x][gridIndex.y].sprite.texture = atlasTexture
	var pos = grid_to_pixel_pos(gridIndex)
	print("[land_cell] landing cell at " + str(gridIndex) + " pixel coords " + str(pos))
	CellGrid[gridIndex.x][gridIndex.y].sprite.position = pos
	
	CellGrid[gridIndex.x][gridIndex.y].sprite.z_index = 1 #set z_index to have cell render in front of background grid
	CellGrid[gridIndex.x][gridIndex.y].sprite.scale = atlasTexture.get_size() / GRID_CELL_PIXEL_COUNT
	
	on_land_cell.emit()

func cell_fall_scan(gridIndex: Vector2i):
	var checkPos = gridIndex
	checkPos.y += 1
	
	if not BoardData.is_valid(checkPos):
		return
		
	if(CellGrid[checkPos.x][checkPos.y].color == CellData.CellColor.EMPTY):
		#nothing below this block, needs to fall
		print("[cell_fall_scan] empty cell below pos " + str(gridIndex) + " set to fall")
		set_state(gridIndex, CellData.CellState.TO_FALL)
		return
		
	if(CellGrid[checkPos.x][checkPos.y].state == CellData.CellState.TO_FALL):
		#block below this one is set to fall
		print("[cell_fall_scan] cell below " + str(gridIndex) + " set to fall")
		set_state(gridIndex, CellData.CellState.TO_FALL)
		return

func matching_square_scan(gridIndex : Vector2i, color : CellData.CellColor):
	var matchDirKeys = []
	
	if CellGrid[gridIndex.x][gridIndex.y].state == CellData.CellState.FALLING \
	or CellGrid[gridIndex.x][gridIndex.y].state == CellData.CellState.TO_FALL:
		print("[matching_square_scan] current cell at " + str(gridIndex) + "  falling, early out")
		return
	
	#check all 4 corners of cell for matching color square, append matching direction to array
	for direction in MATCH_DIR_VALUES.values():
		var matchedDirIndexes = 0
		#print("scan direction = " + str(direction) + "/" + str(MATCH_DIR.keys()[MATCH_DIR_VALUES.find_key(direction)]))
		for dir in direction:
			var checkPos = gridIndex + dir
			if not is_valid(checkPos):
				#print("scan gridIndex " + str(gridIndex) + " in direction " + str(MATCH_DIR.keys()[MATCH_DIR_VALUES.find_key(direction)]) + " not matched, checkPos is out of bounds")
				break
			if CellGrid[checkPos.x][checkPos.y].state == CellData.CellState.FALLING \
			or CellGrid[checkPos.x][checkPos.y].state == CellData.CellState.TO_FALL:
				#don't match if one of the cells is falling
				break
			if CellGrid[checkPos.x][checkPos.y].color != color:
				#print("scan gridIndex " + str(gridIndex) + " in direction " + str(MATCH_DIR.keys()[MATCH_DIR_VALUES.find_key(direction)]) + " not matched, color at checkPos is " + str(CellData.CellColor.keys()[CellGrid[checkPos.x][checkPos.y].color]) + " and color for current cell is " + str(CellData.CellColor.keys()[color]))
				break
			matchedDirIndexes += 1
		
		if matchedDirIndexes == direction.size():
			#all checkPos matched
			matchDirKeys.append(MATCH_DIR_VALUES.find_key(direction))
			
	#handle things when we find matching directions from above
	if matchDirKeys.is_empty():
		return
	
	if CellGrid[gridIndex.x][gridIndex.y].state != CellData.CellState.MATCHED:
		set_state(gridIndex, CellData.CellState.MATCHED)
		
		#we setup the orbit animation if we haven't already cached off the match direction for this cell
		print("[matching_square_scan] setting up matching orbit anim with gridIndex at " + str(gridIndex))
		var orbitSpriteInstance = matchOrbitScene.instantiate() as AnimatedSprite2D
		orbitSpriteInstance.global_position = Vector2(BoardData.grid_to_orbit_pos( gridIndex ))
		orbitSpriteInstance.play("orbit")
		add_child(orbitSpriteInstance)
	
	BoardData.CellGrid[gridIndex.x][gridIndex.y].sprite.texture = get_cell_color_atlas_texture(get_texture_atlas_index_for_level(BoardData.CellGrid[gridIndex.x][gridIndex.y].color) + 2)
	if CellGrid[gridIndex.x][gridIndex.y].matchingShape == Vector2i(-1, -1):
		CellGrid[gridIndex.x][gridIndex.y].matchingShape = gridIndex
	
	for matchDirKey in matchDirKeys:
		#print("[matching_square_scan] gridIndex " + str(gridIndex) + " matched square in dir " + str(MATCH_DIR.keys()[matchDirKey]))
		if not CellGrid[gridIndex.x][gridIndex.y].matchingDir.has(matchDirKey):
			CellGrid[gridIndex.x][gridIndex.y].matchingDir.append(matchDirKey)
		
		for dir in MATCH_DIR_VALUES[matchDirKey]:
			var checkPos = gridIndex + dir
			if is_valid(checkPos):
				if CellGrid[checkPos.x][checkPos.y].state != CellData.CellState.MATCHED:
					print("[matching_square_scan] setting up matching orbit anim with gridIndex at " + str(gridIndex))
					var orbitSpriteInstance = matchOrbitScene.instantiate() as AnimatedSprite2D
					orbitSpriteInstance.global_position = Vector2(BoardData.grid_to_orbit_pos( gridIndex ))
					orbitSpriteInstance.play("orbit")
					add_child(orbitSpriteInstance)
					set_state(checkPos, CellData.CellState.MATCHED)
	
	#first loop to get rightmost matching shape in gridIndex cached, then propogate
	for matchDirKey in matchDirKeys:
		for dir in MATCH_DIR_VALUES[matchDirKey]:
			var checkPos = gridIndex + dir
			if not is_valid(checkPos):
				continue
			if CellGrid[gridIndex.x][gridIndex.y].matchingShape.x < CellGrid[checkPos.x][checkPos.y].matchingShape.x:
				print("[matching_square_scan] found larger matchingShape.x inded - assigning index " + str(gridIndex) + " matchingShape of " + str(CellGrid[checkPos.x][checkPos.y].matchingShape) + " from checkPos " + str(checkPos))
				CellGrid[gridIndex.x][gridIndex.y].matchingShape = CellGrid[checkPos.x][checkPos.y].matchingShape

	for matchDirKey in matchDirKeys:
		for dir in MATCH_DIR_VALUES[matchDirKey]:
			var checkPos = gridIndex + dir
			if not is_valid(checkPos):
				continue
			if CellGrid[gridIndex.x][gridIndex.y].matchingShape.x > CellGrid[checkPos.x][checkPos.y].matchingShape.x:
				print("[matching_square_scan] have larger matchingShape.x index - assigning index " + str(checkPos) + " matchingShape of " + str(CellGrid[gridIndex.x][gridIndex.y].matchingShape))
				CellGrid[checkPos.x][checkPos.y].matchingShape = CellGrid[gridIndex.x][gridIndex.y].matchingShape

func clear_cell(gridIndex : Vector2i):
	print("clearing cell " + str(gridIndex))
	CellGrid[gridIndex.x][gridIndex.y].sprite.queue_free()
	CellGrid[gridIndex.x][gridIndex.y] = CellData.new()
	
func is_valid(gridIndex):
	if gridIndex.x < 0 or gridIndex.x >= GRID_WIDTH or gridIndex.y >= GRID_HEIGHT:
		return false
	return true

func is_free(cellGridPos):
	#check for border
	if not is_valid(cellGridPos):
		return false
	#check for existing placed blocks
	if cellGridPos.x >= 0 and cellGridPos.y >= 0 and CellGrid[cellGridPos.x][cellGridPos.y].color != CellData.CellColor.EMPTY:
		return false
	return true

func can_move_block(blockCellPosition, dir):
	var canMove := true
	var checkPos = []
	for i in 2:
		#check the bottom two blocks
		checkPos.append(blockCellPosition[ i + 2 ] + dir)
		if not is_free(checkPos[i]):
			canMove = false
	return canMove
	
func set_state(gridIndex : Vector2i, newState : CellData.CellState):
	if CellGrid[gridIndex.x][gridIndex.y].state == newState:
		return
	print("[set_state] cell at pos " + str(gridIndex) + " state changed from " + str(CellData.CellState.keys()[CellGrid[gridIndex.x][gridIndex.y].state]) + " to " + str(CellData.CellState.keys()[newState]))
	CellGrid[gridIndex.x][gridIndex.y].state = newState

func get_texture_atlas_index_for_level(color : int):
	return color + ((BoardData.currentLevel - 1) * 4)

func _ready():
	CellGrid = []
	for w in GRID_WIDTH:
		CellGrid.append([])
		#top to bottom
		for h in GRID_HEIGHT:
			#Set a starter value for each position
			CellGrid[w].append(CellData.new(CellData.CellColor.EMPTY))
