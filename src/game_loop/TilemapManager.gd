# This might need to be rewritten to C# or even C++ for performance
extends TileMap
class_name TileMapManager

const FIRE_DAMAGE: int = 1

# It's possible to optimize out frames til spread with hp manipulation
class BurnableTile:
	var burning: bool = false
	var hp: int = 100
	var frames_til_spread = 10

# 2D array with all tiles and their respective hitpoints
var main_map: Array = []
var map_rect: Rect2

# 2D array with all burnable tiles and whether they burn
var burnable_map: Array
var burnable_tilemap: TileMap

func _ready() -> void:
	#self.burnable_tilemap = burnable_tilemap
	
	map_rect = self.get_used_rect()
	
	init_map(main_map, map_rect.size.x, map_rect.size.y, 0)
	init_map(burnable_map, map_rect.size.x, map_rect.size.y, 0)
	generate_map(self, main_map, 25)
	#generate_map(burnable_tilemap, main_map, BurnableTile.new())

func init_map(map_ref: Array, width: int, height: int, value) -> void:
	for x in range(width):
		map_ref.append([])
		for y in range(height):
			map_ref[x].append(value)

func generate_map(tilemap: TileMap, map_ref: Array, value) -> void:
	var map_data: Array = tilemap.get_used_cells()
	
	for tile in map_data:
		map_ref[tile.x-map_rect.position.x][tile.y-map_rect.position.y] = value

func remove_tile(tilemap: TileMap, map_ref: Array, map_pos: Vector2, real_pos: Vector2):
	tilemap.set_cellv(real_pos, -1)
	map_ref[map_pos.x][map_pos.y] = 0

func damage_tile(tilemap: TileMap, map_ref: Array, 
				real_pos: Vector2, damage: int) -> bool:
	var map_pos: Vector2 = Vector2(	real_pos.x-map_rect.position.x, 
									real_pos.y-map_rect.position.y)
	var tile_hp = map_ref[map_pos.x][map_pos.y]
	tile_hp -= damage
	
	if tile_hp <= 0:
		remove_tile(tilemap, map_ref, map_pos, real_pos)
		return true
	else:
		map_ref[map_pos.x][map_pos.y] = tile_hp
		return false
		
# --------------------------------- BURNING ------------------------------------

#func handle_burnable_map() -> void:
#	for tile in burnable_map:
#		if(not burnable_map[tile.x+1][tile.y].burning):
#			pass
#
#func handle_non_burning(pos: Vector2) -> void:
#	var tile = burnable_map[pos.x][pos.y]
#
#	if tile.frames_til_spread < 0:
#		tile.burning = true
#	if tile.frames_til_spread > 0:
#		tile.frames_til_spread -= 1
#
#	burnable_map[pos.x][pos.y] = tile 
#
#func handle_burning(pos: Vector2) -> void:
#	# Spawn some effect or particle or smth?
#	var tile_hp = burnable_map[pos.x][pos.y]
#	tile_hp -= FIRE_DAMAGE
#
#	if tile_hp < 0:
#		remove_tile(burnable_tilemap, burnable_map, pos)
#	else:
#		burnable_map[pos.x][pos.y] = tile_hp
