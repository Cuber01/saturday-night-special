extends PickupableObject

var bullet_scn: PackedScene = preload("res://scenes/Bullet.tscn")

const BULLET_SPEED: int = 120

func _use() -> void:
	var bullet: Bullet = bullet_scn.instance()
	bullet.init($ShootPoint.global_position, 
				Vector2(BULLET_SPEED if facing_right else -BULLET_SPEED,
				0))
	owner.add_child(bullet)
