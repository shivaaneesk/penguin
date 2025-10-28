
extends Node2D

# These constants are inconsistent with the is_within_boundaries function.
const GRID_WIDTH = 59
const GRID_HEIGHT = 27
const WORLD_OFFSET = Vector2i(30, 13)

var fish_1_texture = preload("res://fish1.png")
var fish_2_texture = preload("res://fish2.png")
var fish_3_texture = preload("res://fish3.png")

var grid_data = []
var player_penguin = null
var ai_penguin = null
var player_score = 0
var ai_score = 0

var player_move_direction = Vector2i.ZERO
var ai_move_direction = Vector2i.ZERO
var move_interval = 0.2
var player_move_timer = 0.0
var ai_move_timer = 0.0

@onready var score_label = $ScoreLabel

func world_to_grid(world_pos: Vector2i) -> Vector2i:
	var grid_x = world_pos.x + WORLD_OFFSET.x
	var grid_y = -world_pos.y + WORLD_OFFSET.y
	return Vector2i(grid_x, grid_y)

func grid_to_world(grid_pos: Vector2i) -> Vector2i:
	var world_x = grid_pos.x - WORLD_OFFSET.x
	var world_y = -(grid_pos.y - WORLD_OFFSET.y)
	return Vector2i(world_x, world_y)

func _ready():
	player_penguin = $TileMap/PlayerPenguin
	ai_penguin = $TileMap/AiPenguin
	player_penguin.player_id = 1
	player_penguin.grid_pos = world_to_grid(Vector2i(-59, 1))
	player_penguin.update_position()
	ai_penguin.player_id = 2
	ai_penguin.grid_pos = world_to_grid(Vector2i(-3, 25))
	ai_penguin.update_position()
	setup_board()
	ai_decide_new_move()

func _process(delta):
	score_label.text = "Player: " + str(player_score) + " | AI: " + str(ai_score)
	
	if player_move_direction != Vector2i.ZERO:
		player_move_timer += delta
		if player_move_timer >= move_interval:
			player_move_timer = 0.0
			slide_one_tile(player_penguin, player_move_direction)

	if ai_move_direction != Vector2i.ZERO:
		ai_move_timer += delta
		if ai_move_timer >= move_interval:
			ai_move_timer = 0.0
			slide_one_tile(ai_penguin, ai_move_direction)

func _unhandled_input(event):
	if event.is_action_pressed("move_right"): player_move_direction = Vector2i.RIGHT
	elif event.is_action_pressed("move_left"): player_move_direction = Vector2i.LEFT
	elif event.is_action_pressed("move_up"): player_move_direction = Vector2i.UP
	elif event.is_action_pressed("move_down"): player_move_direction = Vector2i.DOWN

func slide_one_tile(penguin, direction):
	var next_grid_pos = penguin.grid_pos + direction
	
	if not is_within_boundaries(next_grid_pos) or grid_data[next_grid_pos.x][next_grid_pos.y].durability <= 0:
		if penguin.player_id == 1:
			player_move_direction = Vector2i.ZERO
		else:
			ai_move_direction = Vector2i.ZERO
			ai_decide_new_move()
		return

	var target_tile = grid_data[next_grid_pos.x][next_grid_pos.y]
	if penguin.player_id == 1: player_score += target_tile.fish
	else: ai_score += target_tile.fish
	
	target_tile.fish = 0
	target_tile.durability -= 1
	if target_tile.has("sprite_ref") and is_instance_valid(target_tile.sprite_ref):
		target_tile.sprite_ref.queue_free()
		target_tile.erase("sprite_ref")
	if target_tile.durability <= 0:
		$TileMap.erase_cell(0, next_grid_pos)
	
	penguin.grid_pos = next_grid_pos
	penguin.update_position()
	
	if penguin.player_id == 2:
		# The "richest neighbor" AI needs to think after every single step.
		ai_decide_new_move()

# NEW, SMARTER AI "Brain" with a hierarchy of goals.
func ai_decide_new_move():
	var directions = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
	
	# --- Priority 1: Hunt for adjacent fish ---
	var best_hunt_direction = Vector2i.ZERO
	var best_fish_count = 0 # Must be greater than 0
	for direction in directions:
		var neighbor_pos = ai_penguin.grid_pos + direction
		if is_within_boundaries(neighbor_pos) and grid_data[neighbor_pos.x][neighbor_pos.y].durability > 0:
			var fish_on_tile = grid_data[neighbor_pos.x][neighbor_pos.y].fish
			if fish_on_tile > best_fish_count:
				best_fish_count = fish_on_tile
				best_hunt_direction = direction
	
	if best_hunt_direction != Vector2i.ZERO:
		ai_move_direction = best_hunt_direction
		return # Found fish, decision made.

	# --- Priority 2: Maintain momentum if possible ---
	if ai_move_direction != Vector2i.ZERO:
		var next_pos_in_current_dir = ai_penguin.grid_pos + ai_move_direction
		if is_within_boundaries(next_pos_in_current_dir) and grid_data[next_pos_in_current_dir.x][next_pos_in_current_dir.y].durability > 0:
			# The path ahead is clear, so keep going.
			return

	# --- Priority 3: Choose a new, random, safe direction to explore ---
	directions.shuffle() # Randomize the order
	for direction in directions:
		var neighbor_pos = ai_penguin.grid_pos + direction
		if is_within_boundaries(neighbor_pos) and grid_data[neighbor_pos.x][neighbor_pos.y].durability > 0:
			ai_move_direction = direction
			return # Found a safe direction, decision made.

	# --- Priority 4: No safe moves, stop. ---
	ai_move_direction = Vector2i.ZERO
	print("AI is boxed in and cannot move.")

func is_within_boundaries(grid_pos: Vector2i):
	var world_pos = grid_to_world(grid_pos)
	if world_pos.x < -59 or world_pos.x > -3: return false
	if world_pos.y < 1 or world_pos.y > 25: return false
	return true

func game_over(reason: String):
	print("GAME OVER: ", reason)
	if player_score > ai_score: print("Player wins!")
	elif ai_score > player_score: print("AI wins!")
	else: print("It's a draw!")
	get_tree().paused = true

func setup_board():
	# This function remains unchanged
	var fish_spawn_points = [ Vector2i(-59, 25), Vector2i(-59, 21), Vector2i(-59, 17), Vector2i(-59, 13), Vector2i(-59, 9), Vector2i(-59, 5), Vector2i(-55, 1), Vector2i(-55, 5), Vector2i(-55, 9), Vector2i(-55, 13), Vector2i(-55, 17), Vector2i(-55, 21), Vector2i(-55, 25), Vector2i(-51, 25), Vector2i(-51, 21), Vector2i(-51, 17), Vector2i(-51, 13), Vector2i(-51, 9), Vector2i(-51, 5), Vector2i(-51, 1), Vector2i(-47, 1), Vector2i(-47, 5), Vector2i(-47, 9), Vector2i(-47, 13), Vector2i(-47, 17), Vector2i(-47, 21), Vector2i(-47, 25), Vector2i(-43, 25), Vector2i(-43, 21), Vector2i(-43, 18), Vector2i(-43, 13), Vector2i(-43, 9), Vector2i(-43, 5), Vector2i(-43, 2), Vector2i(-39, 1), Vector2i(-39, 5), Vector2i(-39, 9), Vector2i(-39, 13), Vector2i(-39, 17), Vector2i(-39, 21), Vector2i(-39, 25), Vector2i(-35, 25), Vector2i(-35, 21), Vector2i(-35, 17), Vector2i(-35, 13), Vector2i(-35, 9), Vector2i(-35, 5), Vector2i(-35, 1), Vector2i(-31, 1), Vector2i(-31, 5), Vector2i(-31, 9), Vector2i(-31, 13), Vector2i(-31, 17), Vector2i(-31, 21), Vector2i(-31, 25), Vector2i(-27, 25), Vector2i(-27, 21), Vector2i(-27, 17), Vector2i(-27, 13), Vector2i(-27, 9), Vector2i(-27, 5), Vector2i(-27, 1), Vector2i(-23, 1), Vector2i(-23, 5), Vector2i(-23, 9), Vector2i(-23, 13), Vector2i(-23, 17), Vector2i(-23, 21), Vector2i(-23, 25), Vector2i(-19, 25), Vector2i(-19, 21), Vector2i(-19, 17), Vector2i(-19, 13), Vector2i(-19, 10), Vector2i(-19, 5), Vector2i(-19, 1), Vector2i(-15, 1), Vector2i(-15, 5), Vector2i(-15, 9), Vector2i(-15, 13), Vector2i(-15, 17), Vector2i(-15, 21), Vector2i(-15, 25), Vector2i(-11, 25), Vector2i(-11, 21), Vector2i(-11, 17), Vector2i(-11, 13), Vector2i(-11, 9), Vector2i(-11, 5), Vector2i(-11, 1), Vector2i(-7, 1), Vector2i(-7, 5), Vector2i(-7, 9), Vector2i(-7, 13), Vector2i(-7, 17), Vector2i(-7, 21), Vector2i(-7, 25), Vector2i(-3, 21), Vector2i(-3, 17), Vector2i(-3, 13), Vector2i(-3, 9), Vector2i(-3, 5), Vector2i(-3, 1)]
	var fish_types_to_place = []
	for i in range(11): fish_types_to_place.append(3)
	for i in range(22): fish_types_to_place.append(2)
	for i in range(78): fish_types_to_place.append(1)
	grid_data.resize(GRID_WIDTH)
	for x in range(GRID_WIDTH):
		grid_data[x] = []
		grid_data[x].resize(GRID_HEIGHT)
		for y in range(GRID_HEIGHT):
			grid_data[x][y] = { "fish": 0, "durability": 3 }
	fish_spawn_points.shuffle()
	fish_types_to_place.shuffle()
	for i in range(fish_types_to_place.size()):
		if i >= fish_spawn_points.size(): break
		var spawn_pos_world = fish_spawn_points[i]
		var spawn_pos_grid = world_to_grid(spawn_pos_world)
		var fish_amount = fish_types_to_place[i]
		grid_data[spawn_pos_grid.x][spawn_pos_grid.y].fish = fish_amount
		var fish_sprite = Sprite2D.new()
		if fish_amount == 1: fish_sprite.texture = fish_1_texture
		elif fish_amount == 2: fish_sprite.texture = fish_2_texture
		else: fish_sprite.texture = fish_3_texture
		fish_sprite.position = player_penguin.get_pixel_pos_from_grid_pos(spawn_pos_grid)
		fish_sprite.scale = Vector2(0.1, 0.1)
		grid_data[spawn_pos_grid.x][spawn_pos_grid.y]["sprite_ref"] = fish_sprite
		$TileMap/FishContainer.add_child(fish_sprite)
	print("Game board set up with custom fish placement!")
