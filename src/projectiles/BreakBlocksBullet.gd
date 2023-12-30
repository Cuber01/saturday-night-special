extends Bullet

var tilemap: TileMap

# world has to be optional due to how 
func init(pos: Vector2, vel: Vector2, lifespan: int, 
		 damage: int, world: TileMap = null) -> void:
	.init(pos, vel, lifespan, damage)
	
	if world == null: # In case I forgor...
		push_error("BreakBlocksBullet: World is null.")
	self.tilemap = world
	change_state(State.FLYING)

func collision_response(collision: KinematicCollision2D) -> void:
	var colliding_body = collision.collider
		
	if colliding_body.has_method("take_damage"):
		colliding_body.take_damage(damage)
	elif colliding_body.name == "BasicTilemap":
		var cell: Vector2 = tilemap.world_to_map(collision.position - collision.normal)
		tilemap.set_cellv(cell, -1)
		tilemap.update_bitmask_area(cell) # TODO, not sure if we want this. Depends on the final tilemap

