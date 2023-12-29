extends Node
class_name TilemapManager

# We'll keep two tilemaps: one normal and one burnable

# 2D array with all tiles and their respective hitpoints
var map: Array 

# 2D array with all burnable tiles and whether they burn
var burnable_map: Array

func handle_burn() -> void:
	# enumerate through all tiles, if true, 
	# spawn fire effect, damage tile and attempt to spread
	pass

func damage_tile(position: Vector2, damage: int):
	# if hp < 0: kill tile
	pass
	
