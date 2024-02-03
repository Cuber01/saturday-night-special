extends BaseGun

func _ready() -> void:
	bulletScene = preload("res://scenes/projectiles/Bullet.tscn")
	bulletSpeed = 300
	bulletLifetime = 30
	bulletSpread = 0.1
	ammoPerMag = 30
	bulletDamage = 5
	recoilForce = Vector2(100,-20)
	delayBetweenShots = 10
	mode = Mode.AUTOMATIC

	ammo_left = ammoPerMag
	mags_left = 0

func _shoot():
	spawn_bullet()
