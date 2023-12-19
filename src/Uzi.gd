extends PickupableObject

var bullet_scn: PackedScene = preload("res://scenes/projectiles/Bullet.tscn")
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const BULLET_INNACURACY: float = 10.0

const BULLET_SPEED: int = 120
const BULLET_LIFETIME: int = 100
const RECOIL_FORCE: Vector2 = Vector2(100,-20)
const DELAY_BETWEEN_SHOTS: int = 10

var current_delay: int = 0
var ammo_left: int = 30

func _overriden_update() -> void:
	if current_delay > 0:
		current_delay -= 1

func _use(user) -> void:
	if current_delay > 0:
		return
	
	if ammo_left > 0:
		handle_recoil(user)
		shoot()
		ammo_left -= 1
		current_delay = DELAY_BETWEEN_SHOTS
		
		if ammo_left == 0:
			can_despawn = true

func shoot():
	spawn_bullet()

func spawn_bullet():
	var bullet: KinematicBody2D = bullet_scn.instance()
	bullet.init($ShootPoint.global_position, 
				Vector2(BULLET_SPEED if facing_right else -BULLET_SPEED,
				rng.randf_range(-BULLET_INNACURACY, BULLET_INNACURACY)),
				BULLET_LIFETIME)
	world.add_child(bullet)

func handle_recoil(user) -> void:
	user.velocity.x += RECOIL_FORCE.x if not facing_right else -RECOIL_FORCE.x
	user.velocity.y += RECOIL_FORCE.y
