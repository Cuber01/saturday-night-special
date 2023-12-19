extends Bullet

var tilemap: TileMap

# world has to be optional due to how 
func init(pos: Vector2, vel: Vector2, lifespan: int, world: TileMap = null) -> void:
	self.position = pos
	self.velocity = vel
	self.lifetime = lifespan
	if world == null: # DEBUG
		push_error("BreakBlocksBullet: World is null.")
	self.tilemap = world
	change_state(State.FLYING)

func collision_response(collision: KinematicCollision2D) -> void:
	var colliding_body = collision.collider
		
	if colliding_body is Player:
		colliding_body.die()
	elif colliding_body.name == "BasicTilemap":
		var cell = tilemap.world_to_map(collision.position - collision.normal)
		tilemap.set_cellv(cell, -1)
