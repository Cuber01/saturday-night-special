# This might need to be rewritten to C# or even C++ for performance
extends Node
class_name TilemapManager

const FIRE_DAMAGE: int = 1

# It's possible to optimize out frames til spread with hp manipulation
class BurnableTile:
	var burning: bool = false
	var hp: int = 100
	var frames_til_spread = 10

# 2D array with all tiles and their respective hitpoints
var main_map: Array 

# 2D array with all burnable tiles and whether they burn
var burnable_map: Array

# Get a global burnable tilemap and main tilemap, doesn't make much sense to pass them everywhere tbh

func generate_map_from_lvl(main_tilemap: TileMap, burnable_tilemap: TileMap):
	generate_map(main_tilemap, main_map, 100)
	generate_map(burnable_tilemap, main_map, BurnableTile.new())

func generate_map(tilemap: TileMap, map_ref: Array, value) -> void:
	var map_data: Array = tilemap.get_used_cells()
	
	var map_x: int = 0
	var map_y: int = -1 # Will get updated to 0 at first loop
	
	var current_real_y: int = -1
	for tile in map_data:
		if tile.position.y > current_real_y:
			current_real_y = tile.position.y
			map_y += 1
			map_x = 0
		
		# This may need different handling for different tiles
		map_ref[map_x][map_y] = value # tilemap.get_cellv(tile)
		map_x += 1

func handle_burnable_map() -> void:
	for tile in burnable_map:
		if(not burnable_map[tile.x+1][tile.y].burning):
			pass

func handle_non_burning(pos: Vector2) -> void:
	var tile = burnable_map[pos.x][pos.y]
	
	if tile.frames_til_spread < 0:
		tile.burning = true
	if tile.frames_til_spread > 0:
		tile.frames_til_spread -= 1
				
	burnable_map[pos.x][pos.y] = tile 

func handle_burning(pos: Vector2) -> void:
	# Spawn some effect or particle or smth?
	var tile_hp = burnable_map[pos.x][pos.y]
	tile_hp -= FIRE_DAMAGE
	
	if tile_hp < 0:
		remove_tile(tilemap, map_ref, map_pos)
	else:
		map_ref[map_pos.x][map_pos.y] = tile_hp

func remove_tile(tilemap: TileMap, map_ref: Array, pos: Vector2):
	tilemap.set_cellv(pos, -1)
	map_ref[pos.x][pos.y] = 0

func damage_tile(tilemap: TileMap, map_ref: Array, position: Vector2, damage: int) -> void:
	var map_pos: Vector2 = tilemap.world_to_map(position)
	var tile_hp = map_ref[map_pos.x][map_pos.y]
	tile_hp -= damage
	
	if tile_hp < 0:
		remove_tile(tilemap, map_ref, map_pos)
	else:
		map_ref[map_pos.x][map_pos.y] = tile_hp
