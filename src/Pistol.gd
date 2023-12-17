extends PickupableObject

var bullet_scn: PackedScene = preload("res://scenes/projectiles/Bullet.tscn")

const BULLET_SPEED: int = 120
const RECOIL_FORCE: Vector2 = Vector2(100,-20)

var ammo_left: int = 6

func _use(user) -> void:
	if ammo_left > 0:
		handle_recoil(user)
		spawn_bullet()
		ammo_left -= 1
		
		if ammo_left == 0:
			can_despawn = true

func handle_recoil(user) -> void:
	user.velocity.x += RECOIL_FORCE.x if not facing_right else -RECOIL_FORCE.x
	user.velocity.y += RECOIL_FORCE.y
	user.is_in_air = true

func spawn_bullet():
	var bullet: KinematicBody2D = bullet_scn.instance()
	bullet.init($ShootPoint.global_position, 
				Vector2(BULLET_SPEED if facing_right else -BULLET_SPEED,
				0))
	world.add_child(bullet)
