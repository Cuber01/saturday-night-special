# This might need to be rewritten to C# or even C++ for performance
extends Node
class_name TileMapManager

const FIRE_DAMAGE: int = 1

# It's possible to optimize out frames til spread with hp manipulation
class BurnableTile:
	var burning: bool = false
	var hp: int = 100
	var frames_til_spread = 10

# 2D array with all tiles and their respective hitpoints
var main_map: Array = []

# 2D array with all burnable tiles and whether they burn
var burnable_map: Array
var burnable_tilemap: TileMap

func _init(main_tilemap: TileMap, burnable_tilemap: TileMap) -> void:
	#self.burnable_tilemap = burnable_tilemap
	init_map(main_map, 100, 100, 0) 
	#init_map(burnable_map, 100, 100, 0)
	generate_map(main_tilemap, main_map, 100)
	#generate_map(burnable_tilemap, main_map, BurnableTile.new())

func init_map(map_ref: Array, width: int, height: int, value) -> void:
	for x in range(width):
		map_ref.append([])
		for y in range(height):
			map_ref[x].append(value)

func generate_map(tilemap: TileMap, map_ref: Array, value) -> void:
	var map_data: Array = tilemap.get_used_cells()
	
	for tile in map_data:
		map_ref[tile.x][tile.y] = value

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
		
# --------------------------------- BURNING ------------------------------------

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
		remove_tile(burnable_tilemap, burnable_map, pos)
	else:
		burnable_map[pos.x][pos.y] = tile_hp
