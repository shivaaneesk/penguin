extends Node2D

var player_id: int
var grid_pos: Vector2i

# IMPORTANT: Make sure this value matches your tile size in pixels!
const TILE_SIZE = 16 

# This function calculates the target pixel position for a given grid position.
func get_pixel_pos_from_grid_pos(p_grid_pos: Vector2i) -> Vector2:
	const OFFSET = TILE_SIZE / 2
	var pixel_pos_x = p_grid_pos.x * TILE_SIZE + OFFSET
	var pixel_pos_y = p_grid_pos.y * TILE_SIZE + OFFSET
	return Vector2(pixel_pos_x, pixel_pos_y)

# This function instantly sets the penguin's visual position.
func update_position():
	self.position = get_pixel_pos_from_grid_pos(grid_pos)
