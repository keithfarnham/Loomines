extends Sprite2D

class_name ActivePiece

enum rotateDir {ROTATE_LEFT, ROTATE_RIGHT}

var activeBlockColors
var nextBlock

var textures = load("res://art/lumines_tiles.png")
var cellSprites = []

@onready var rotateLeftSFX = $RotateLeft as AudioStreamPlayer
@onready var rotateRightSFX = $RotateRight as AudioStreamPlayer
@onready var landBlockSFX = $LandBlock as AudioStreamPlayer

signal fail_top_out

var steps
const stepsReq : int = 200
var autoDropSpeed : float
const startPos := [Vector2i(7, -2), Vector2i(8, -2), Vector2i(7, -1), Vector2i(8, -1)] #block starts on grid X = 7 & 8, Y = -2 & -1
var currentPos = []

func create_block():
	steps = [0, 0, 0]
	currentPos = startPos
	activeBlockColors = pick_block()
	draw_block(activeBlockColors, currentPos)

func pick_block():
	#returns index of random block from Shapes
	return BlockData.cells[BlockData.BlockShape.values().pick_random()]

func draw_block(blockToDraw, pos):
	print("[draw_block] drawing block at pos " + str(pos))
	for i in BlockData.BLOCK_CELL_COUNT:
		var atlasTexture = BoardData.get_cell_color_atlas_texture(BoardData.get_texture_atlas_index_for_level(blockToDraw[i]))
		cellSprites[i].texture = atlasTexture
		
		#keeping all conversion from CellGrid index to pixel location in places that modify cellSprites[].position
		cellSprites[i].position = Vector2i(BoardData.grid_to_pixel_pos(pos[i]))
		
		cellSprites[i].scale = atlasTexture.get_size() / BoardData.GRID_CELL_PIXEL_COUNT

func land_block_to_fall(currentPos):
	#handle blocks landing out of the grid's bounds with room underneath them to fall
	if BoardData.CellGrid[currentPos[2].x][0].color == CellData.CellColor.EMPTY:
		for yIndex in range(BoardData.GRID_HEIGHT - 1, 0, -1):
			if BoardData.CellGrid[currentPos[2].x][yIndex].color == CellData.CellColor.EMPTY:
				BoardData.CellGrid[currentPos[2].x][yIndex] = CellData.new(BoardData.get_texture_atlas_index_for_level(activeBlockColors[2]))
				BoardData.CellGrid[currentPos[2].x][yIndex].sprite = Sprite2D.new()
				BoardData.CellGrid[currentPos[2].x][yIndex].sprite.texture = BoardData.get_cell_color_atlas_texture(BoardData.get_texture_atlas_index_for_level(activeBlockColors[2]))
				BoardData.CellGrid[currentPos[2].x][yIndex].sprite.position = BoardData.grid_to_pixel_pos(currentPos[2])
				BoardData.CellGrid[currentPos[2].x][yIndex].sprite.z_index = 1
				if BoardData.CellGrid[currentPos[2].x][yIndex].sprite.get_parent() == null:
					add_child(BoardData.CellGrid[currentPos[2].x][yIndex].sprite)
				BoardData.set_state(Vector2i(currentPos[2].x, yIndex), CellData.CellState.FALLING)
				if yIndex == 0:
					#only have space for 1 block, early out
					break
				BoardData.CellGrid[currentPos[0].x][yIndex - 1] = CellData.new(BoardData.get_texture_atlas_index_for_level(activeBlockColors[0]))
				BoardData.CellGrid[currentPos[0].x][yIndex - 1].color = BoardData.get_texture_atlas_index_for_level(activeBlockColors[0])
				BoardData.CellGrid[currentPos[0].x][yIndex - 1].sprite.texture = BoardData.get_cell_color_atlas_texture(BoardData.get_texture_atlas_index_for_level(activeBlockColors[0]))
				BoardData.CellGrid[currentPos[0].x][yIndex - 1].sprite.position = BoardData.grid_to_pixel_pos(currentPos[0])
				BoardData.CellGrid[currentPos[0].x][yIndex - 1].sprite.z_index = 1
				if BoardData.CellGrid[currentPos[0].x][yIndex - 1].sprite.get_parent() == null:
					add_child(BoardData.CellGrid[currentPos[0].x][yIndex - 1].sprite)
				BoardData.set_state(Vector2i(currentPos[0].x, yIndex - 1), CellData.CellState.FALLING)
				break
	if BoardData.CellGrid[currentPos[3].x][0].color == CellData.CellColor.EMPTY:
		for yIndex in range(BoardData.GRID_HEIGHT - 1, 0, -1):
			if BoardData.CellGrid[currentPos[3].x][yIndex].color == CellData.CellColor.EMPTY:
				BoardData.CellGrid[currentPos[3].x][yIndex] = CellData.new(BoardData.get_texture_atlas_index_for_level(activeBlockColors[3]))
				BoardData.CellGrid[currentPos[3].x][yIndex].sprite = Sprite2D.new()
				BoardData.CellGrid[currentPos[3].x][yIndex].sprite.texture = BoardData.get_cell_color_atlas_texture(BoardData.get_texture_atlas_index_for_level(activeBlockColors[3]))
				BoardData.CellGrid[currentPos[3].x][yIndex].sprite.position = BoardData.grid_to_pixel_pos(currentPos[3])
				BoardData.CellGrid[currentPos[3].x][yIndex].sprite.z_index = 1
				if BoardData.CellGrid[currentPos[3].x][yIndex].sprite.get_parent() == null:
					add_child(BoardData.CellGrid[currentPos[3].x][yIndex].sprite)
				BoardData.set_state(Vector2i(currentPos[3].x, yIndex), CellData.CellState.FALLING)
				if yIndex == 0:
					#only have space for 1 block, early out
					break
				BoardData.CellGrid[currentPos[1].x][yIndex - 1] = CellData.new(BoardData.get_texture_atlas_index_for_level(activeBlockColors[1]))
				BoardData.CellGrid[currentPos[1].x][yIndex - 1].color = BoardData.get_texture_atlas_index_for_level(activeBlockColors[1])
				BoardData.CellGrid[currentPos[1].x][yIndex - 1].sprite.texture = BoardData.get_cell_color_atlas_texture(BoardData.get_texture_atlas_index_for_level(activeBlockColors[1]))
				BoardData.CellGrid[currentPos[1].x][yIndex - 1].sprite.position = BoardData.grid_to_pixel_pos(currentPos[1])
				BoardData.CellGrid[currentPos[1].x][yIndex - 1].sprite.z_index = 1
				if BoardData.CellGrid[currentPos[1].x][yIndex - 1].sprite.get_parent() == null:
					add_child(BoardData.CellGrid[currentPos[1].x][yIndex - 1].sprite)
				BoardData.set_state(Vector2i(currentPos[1].x, yIndex - 1), CellData.CellState.FALLING)
				break
func land_block():
	print("[land_block] landing at " + str(currentPos))
	landBlockSFX.play()
	if currentPos[2].y == -1 or currentPos[3].y == -1:
		land_block_to_fall(currentPos)
		return
	for index in BlockData.BLOCK_CELL_COUNT:
		print("[land_block] landing cell currentPos[index] " + str(currentPos[index]))
		BoardData.CellGrid[currentPos[index].x][currentPos[index].y] = CellData.new(activeBlockColors[index] as CellData.CellColor)
		BoardData.land_cell(Vector2i(currentPos[index].x, currentPos[index].y), activeBlockColors[index] as CellData.CellColor)
		#initialize empty cells
		if BoardData.CellGrid[currentPos[index].x][currentPos[index].y].sprite.get_parent() == null:
			add_child(BoardData.CellGrid[currentPos[index].x][currentPos[index].y].sprite)
	#need to land the cells first before scanning for falling/matching
	for index in BlockData.BLOCK_CELL_COUNT:
		#doing fall scan before matching check 
		var gridIndex = Vector2i(currentPos[BlockData.BLOCK_CELL_COUNT - index - 1].x, currentPos[BlockData.BLOCK_CELL_COUNT - index - 1].y)
		BoardData.cell_fall_scan(gridIndex)

func move_block(dir):
	if BoardData.can_move_block(currentPos, dir):
		var newPos = []
		for i in BlockData.BLOCK_CELL_COUNT:
			newPos.append(currentPos[i] + dir)
			cellSprites[i].position += dir * BoardData.GRID_CELL_PIXEL_COUNT as Vector2
		
		currentPos = newPos
	elif dir == Vector2i.DOWN:
		if (currentPos[3].y == -1 and BoardData.CellGrid[currentPos[3].x][currentPos[3].y + 1].color != CellData.CellColor.EMPTY) \
			and (currentPos[2].y == -1 and BoardData.CellGrid[currentPos[2].x][currentPos[2].y + 1].color != CellData.CellColor.EMPTY):
			fail_top_out.emit()
			return
		print(str(Time.get_ticks_msec()) + " landing block")
		land_block()
		create_block()

func rotate_block(dir):
	var msPerBeat = 60000.0 / LevelData.BPM[BoardData.currentLevel]

	var prevPos = []
	for i in BlockData.BLOCK_CELL_COUNT:
		prevPos.append(cellSprites[i].position)
		
	var rotatedBlock = []
	var active = activeBlockColors
	if(dir == rotateDir.ROTATE_RIGHT):
		rotatedBlock.append(active[2])
		rotatedBlock.append(active[0])
		rotatedBlock.append(active[3])
		rotatedBlock.append(active[1])
		cellSprites[0].position = prevPos[1]
		cellSprites[1].position = prevPos[3]
		cellSprites[2].position = prevPos[0]
		cellSprites[3].position = prevPos[2]
		rotateRightSFX.play()
	if(dir == rotateDir.ROTATE_LEFT):
		rotatedBlock.append(active[1])
		rotatedBlock.append(active[3])
		rotatedBlock.append(active[0])
		rotatedBlock.append(active[2])
		cellSprites[0].position = prevPos[2]
		cellSprites[1].position = prevPos[0]
		cellSprites[2].position = prevPos[3]
		cellSprites[3].position = prevPos[1]
		rotateLeftSFX.play()
	activeBlockColors = rotatedBlock
	
func handle_inputs():
	if Input.is_action_pressed("ui_left"):
		steps[0] += 50
	if Input.is_action_pressed("ui_right"):
		steps[1] += 50
	if Input.is_action_pressed("ui_down"):
		steps[2] += 50
	if Input.is_action_just_released("RotateLeft"):
		rotate_block(rotateDir.ROTATE_LEFT)
	if Input.is_action_just_released("RotateRight"):
		rotate_block(rotateDir.ROTATE_RIGHT)

func setup_cell_sprites():
	for i in BlockData.BLOCK_CELL_COUNT:
		var newSprite := Sprite2D.new()
		cellSprites.append(newSprite)
		add_child(cellSprites[i])
		
func setup_sfx():
	rotateLeftSFX.stream = load(LevelData.RotateLeftSFX[BoardData.currentLevel])
	rotateRightSFX.stream = load(LevelData.RotateRightSFX[BoardData.currentLevel])
	landBlockSFX.stream = load(LevelData.LandBlockSFX[BoardData.currentLevel])
	
func on_level_change():
	if BoardData.currentLevel > BoardData.Levels.size():
		return
	#audio stuff
	setup_sfx()
	landBlockSFX.volume_db += 2
	
	#redraw sprites
	draw_block(activeBlockColors, currentPos)

func _ready():
	BoardData.on_level_change.connect(on_level_change)
	autoDropSpeed = 1.0
	setup_cell_sprites()
	setup_sfx()

func _process(delta):
	handle_inputs()
	steps[2] += autoDropSpeed
	for i in steps.size():
		if steps[i] > stepsReq:
			move_block(BoardData.DIRECTIONS[i])
			steps[i] = 0
