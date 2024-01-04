extends Bullet

# world has to be optional due to how 
func init(pos: Vector2, vel: Vector2, lifespan: int, 
		 damage: int, world: TileMap) -> void:
	.init(pos, vel, lifespan, damage, world)
	
	change_state(State.FLYING)

func collision_response(collision: KinematicCollision2D) -> void:
	var colliding_body = collision.collider
		
	if colliding_body.has_method("take_damage"):
		colliding_body.take_damage(damage)
	elif colliding_body.name == "BasicTilemap":
		var cell: Vector2 = world.world_to_map(collision.position - collision.normal)
		world.set_cellv(cell, -1)
		world.update_bitmask_area(cell) # TODO, not sure if we want this. Depends on the final tilemap

