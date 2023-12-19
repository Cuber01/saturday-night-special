extends PickupableObject

var bullet_scn: PackedScene = preload("res://scenes/projectiles/Bullet.tscn")
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const BULLET_SPEED: int = 120
const BULLET_INNACURACY: float = 10.0
const BULLETS_PER_SHOT: int = 10
const BULLET_LIFETIME: int = 30

const RELOAD_TIME: int = 2
const AMMO_PER_MAG: int = 1
const RECOIL_FORCE: Vector2 = Vector2(300,-60)

var mags_left: int = 3
var ammo_left: int = AMMO_PER_MAG
var reloading: bool = false

func _use(user) -> void:
	if reloading: return
	
	if ammo_left > 0:
		handle_recoil(user)
		shoot()	
	elif mags_left > 0:
		reload()
		
	if mags_left == 0 and ammo_left == 0:
		can_despawn = true

func shoot():
	for i in BULLETS_PER_SHOT:
		spawn_bullet()
	ammo_left -= 1

func reload():
	reloading = true
	$ReloadTimer.start(RELOAD_TIME)

func handle_recoil(user) -> void:
	user.velocity.x += RECOIL_FORCE.x if not facing_right else -RECOIL_FORCE.x
	user.velocity.y += RECOIL_FORCE.y

func spawn_bullet():
	var bullet: KinematicBody2D = bullet_scn.instance()
	bullet.init($ShootPoint.global_position, 
				Vector2(BULLET_SPEED if facing_right else -BULLET_SPEED,
				rng.randf_range(-BULLET_INNACURACY, BULLET_INNACURACY)),
				BULLET_LIFETIME)
	world.add_child(bullet)

func _on_ReloadTimer_timeout():
	reloading = false
	ammo_left = AMMO_PER_MAG
	mags_left -= 1 
