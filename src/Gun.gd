extends PickupableObject
class_name BaseGun

enum Mode {
		MANUAL,
		AUTOMATIC
	}

# _ready template:
#func _ready() -> void:
#	bulletScene = preload()
#	bulletSpeed =
#	bulletLifetime = 
#	bulletSpread =
#	ammoPerMag = 
#	reloadTime = 
#	recoilForce = 
#	delayBetweenShots = 
#	mode =
#
#	ammo_left = ammoPerMag
#	mags_left = 


# Stats (these are to be assigned only in _ready)
var bulletScene: PackedScene = null # Scene from which we instantiate the bullet
var bulletSpeed: int                # Bullet flying speed in x
var bulletLifetime: int             # Time before the bullet goes into DEATH_STAGE_1
var bulletSpread: float             # Determines max and min value of y bullet spread
var ammoPerMag: int = 6             # Ammunition per each mag. Total ammo if there are no mags
var reloadTime: int = 0             # How much time it takes to load a new mag
var recoilForce: Vector2            # Force applied to the player upon shooting
var delayBetweenShots: int          # Delay between shots for AUTOMATIC weapons
var mode                            # MANUAL or AUTOMATIC shooting mode

# Ammo management
var ammo_left: int     # Ammo left in current mag
var mags_left: int = 0 # Mags left

# Other
var shooting_blocked: bool = false # Weapons are blocked when reloading and when player is holding the button on MANUAL
var current_delay: int = 0 # Delay for automatic weapons
var reloading: bool = false

signal reloaded

func _use(user) -> void:
	if shooting_blocked or reloading:
		return
	
	if current_delay > 0:
		current_delay -= 1
		return
	
	if ammo_left > 0:
		_shoot()
		handle_recoil(user)
		ammo_left -= 1
		
		if mode == Mode.MANUAL:
			shooting_blocked = true
		else:
			current_delay = delayBetweenShots
		
		if mags_left == 0 and ammo_left == 0:
			can_despawn = true
	elif mags_left > 0:
		reload()

# Override
func _shoot():
	push_error("_shoot(): No override")

func spawn_bullet():
	var bullet: KinematicBody2D = bulletScene.instance()
	bullet.init($ShootPoint.global_position, 
				Vector2(bulletSpeed if facing_right else -bulletSpeed,
				Global.rng.randf_range(-bulletSpread, bulletSpread)),
				bulletLifetime,
				world)
	world.add_child(bullet)

func reload():
	reloading = true
	$ReloadTimer.start(reloadTime)

func _overriden_update():
	if button_released:
		shooting_blocked = false
		button_released = false

func handle_recoil(user) -> void:
	user.velocity.x += recoilForce.x if not facing_right else -recoilForce.x
	user.velocity.y += recoilForce.y
	
func _on_ReloadTimer_timeout():
	reloading = false
	_reloaded_effect()
	ammo_left = ammoPerMag
	mags_left -= 1 
	
# Override
func _reloaded_effect():
	pass
