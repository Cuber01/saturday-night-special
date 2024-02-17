extends Bullet


func collision_response(collision: KinematicCollision2D) -> bool:
	var colliding_body = collision.collider
	
	if colliding_body.has_method("take_damage"):
			var was_pierced: bool = colliding_body.take_damage(damage)
			if piercing:
				return was_pierced
			else:
				 return false
		
	return false
