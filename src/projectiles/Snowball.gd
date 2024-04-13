extends Bullet

func _ready() -> void:
	always_spawn_spark = true
	spark_gfx = preload("res://scenes/gfx/particles/SnowballHit.tscn")

func _collision_response(collision: KinematicCollision2D) -> bool:
	SoundManager.play_sound(Global.rng.randi_range(15, 16))
	
	var colliding_body = collision.collider
	
	if colliding_body.has_method("take_damage"):
			var was_pierced: bool = colliding_body.take_damage(damage,
												 Global.DamageType.FREEZE)
			if piercing:
				return was_pierced
			else:
				 return false
		
	return false
