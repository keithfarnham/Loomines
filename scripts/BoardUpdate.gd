extends Node

@onready var clearingLine = $"../ClearingLine" as ClearingLine
@onready var currentLevelUI = $CurrentLevel as RichTextLabel

var textures = load("res://art/lumines_tiles.png")

var runMatchScan := false

func falling_blocks_update(delta):
	for w in BoardData.GRID_WIDTH:
		var distanceToFall = 0
		for h in range (BoardData.GRID_HEIGHT - 1, -1, -1):
			if BoardData.CellGrid[w][h].color == CellData.CellColor.EMPTY:
				distanceToFall += 1
				continue
			
			if BoardData.CellGrid[w][h].state == CellData.CellState.TO_FALL:
				if distanceToFall == 0:
					print("[falling_blocks_update] ERROR distance to fall shouldn't be 0, this cell probably shouldn't be set to fall")
					
				if h + distanceToFall > BoardData.GRID_HEIGHT:
					print("[falling_blocks_update] ERROR trying to make a block fall below the border, resetting distanceToFall to 0 in attempt to avoid problems")
					distanceToFall = 0
				#set FALLING state and copy cell data to target cell destination to handle sprite lerp
				BoardData.set_state(Vector2i(w, h), CellData.CellState.FALLING)
				BoardData.CellGrid[w][h + distanceToFall] = BoardData.CellGrid[w][h]
				BoardData.CellGrid[w][h] = CellData.new()
				print("[falling_blocks_update] Cell at " + str(Vector2i(w, h)) + " will fall to " + str(Vector2i(w, h + distanceToFall)))
		
			elif BoardData.CellGrid[w][h].state == CellData.CellState.FALLING:
				var gridIndex = Vector2(w, h)
				print("[falling_blocks_update] cell at " + str(gridIndex) + " is falling, sprite y pos " + str(BoardData.CellGrid[w][h].sprite.position.y) + " and pixel to grid = " + str(BoardData.pixel_to_grid_pos( BoardData.CellGrid[w][h].sprite.position ).y) + " expecting >=" + str(gridIndex.y))
				if BoardData.pixel_to_grid_pos( BoardData.CellGrid[w][h].sprite.position ).y >= gridIndex.y:
					#sprite made it to landing place
					BoardData.land_cell(gridIndex, BoardData.CellGrid[w][h].color)
				else:
					print("gridIndex " + str(gridIndex) + " is falling")
					BoardData.CellGrid[w][h].sprite.position.y += delta * 720
			
			else: #if cell isn't currently falling, check if it should fall
				BoardData.cell_fall_scan(Vector2i(w, h))

func matching_blocks_update(gridIndex : Vector2i):
	if gridIndex.x == clearingLine.get_clear_cell():
		#cell is matched and clear line has touched it
		BoardData.CellGrid[gridIndex.x][gridIndex.y].clearLineTouched = true
		BoardData.CellGrid[gridIndex.x][gridIndex.y].sprite.texture = BoardData.get_cell_color_atlas_texture(BlockData.BLOCK_CLEARING_ATLAS_INDEX)
	
	if BoardData.CellGrid[gridIndex.x][gridIndex.y].clearLineTouched \
	and BoardData.CellGrid[gridIndex.x][gridIndex.y].matchingShape.x == clearingLine.get_clear_cell() - 1:
		#clearing line has hit the rightmost x value of the matching shape
		print("[matching_blocks_update] going to clear cell at " + str(gridIndex) + " and matching shape " + str(BoardData.CellGrid[gridIndex.x][gridIndex.y].matchingShape))
		BoardData.set_state(Vector2i(gridIndex.x, gridIndex.y), CellData.CellState.CLEARING)

func clear_blocks_update(gridIndex : Vector2i):
	BoardData.clear_cell(Vector2i(gridIndex.x, gridIndex.y))

func matching_blocks_scan():
	for w in range (BoardData.GRID_WIDTH - 1, -1, -1):
		for h in range (BoardData.GRID_HEIGHT - 1, -1, -1):
			if BoardData.CellGrid[w][h].state == CellData.CellState.CLEARING\
			or BoardData.CellGrid[w][h].color == CellData.CellColor.EMPTY:
				continue
			BoardData.matching_square_scan(Vector2i(w, h), BoardData.CellGrid[w][h].color)

func on_land_cell():
	runMatchScan = true
	
func on_clearing_line_reset():
	if BoardData.score >= BoardData.LEVEL_SCORE_REQ[BoardData.currentLevel]:
		BoardData.currentLevel += 1
		BoardData.on_level_change.emit()
		currentLevelUI.text = "Level: " + str(BoardData.currentLevel)
		clearingLine.on_song_start()
		for xIndex in BoardData.GRID_WIDTH:
			for yIndex in BoardData.GRID_HEIGHT:
				if BoardData.CellGrid[xIndex][yIndex].color == CellData.CellColor.EMPTY:
					continue
				#update sprites for all placed cells on board
				var gridIndex = Vector2i(xIndex, yIndex)
				BoardData.CellGrid[xIndex][yIndex].sprite.texture = BoardData.get_cell_color_atlas_texture(BoardData.get_texture_atlas_index_for_level(BoardData.CellGrid[xIndex][yIndex].color))

func _ready():
	BoardData.on_land_cell.connect(on_land_cell)
	clearingLine.on_reset.connect(on_clearing_line_reset)

func _process(delta):
	if(BoardData.CellGrid == null):
		return

	falling_blocks_update(delta)
	
	if(runMatchScan):
		matching_blocks_scan()
		runMatchScan = false
	var numOfCellsCleared = 0
	for xIndex in BoardData.GRID_WIDTH:
		for yIndex in BoardData.GRID_HEIGHT:
			var gridIndex = Vector2i(xIndex, yIndex)
			
			match BoardData.CellGrid[xIndex][yIndex].state:
				CellData.CellState.MATCHED:
					matching_blocks_update(gridIndex)
				CellData.CellState.CLEARING:
					numOfCellsCleared += 1
					clear_blocks_update(gridIndex)
	if numOfCellsCleared > 0:
		BoardData.score += numOfCellsCleared

