extends PickupableObject

var bullet_scn: PackedScene = preload("res://scenes/projectiles/Bullet.tscn")
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const BULLET_SPEED: int = 120
const BULLET_INNACURACY: float = 10.0
const BULLETS_PER_SHOT: int = 10
const BULLET_LIFETIME: int = 30

const RECOIL_FORCE: Vector2 = Vector2(300,-60)

var ammo_left: int = 2

func _use(user) -> void:
	if ammo_left > 0:
		handle_recoil(user)
		shoot()
		ammo_left -= 1
		
		if ammo_left == 0:
			can_despawn = true

func handle_recoil(user) -> void:
	user.velocity.x += RECOIL_FORCE.x if not facing_right else -RECOIL_FORCE.x
	user.velocity.y += RECOIL_FORCE.y
	user.is_in_air = true

func shoot():
	for i in BULLETS_PER_SHOT:
		spawn_bullet()

func spawn_bullet():
	var bullet: KinematicBody2D = bullet_scn.instance()
	bullet.init($ShootPoint.global_position, 
				Vector2(BULLET_SPEED if facing_right else -BULLET_SPEED,
				rng.randf_range(-BULLET_INNACURACY, BULLET_INNACURACY)),
				BULLET_LIFETIME)
	world.add_child(bullet)
