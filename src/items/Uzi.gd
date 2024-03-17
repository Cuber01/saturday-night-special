extends BaseGun

func _ready() -> void:
	bulletScene = preload("res://scenes/projectiles/Bullet.tscn")
	bulletSpeed = 500
	bulletLifetime = 20
	bulletSpread = 0.1
	ammoPerMag = 30
	bulletDamage = 5
	recoilForce = Vector2(100,-20)
	delayBetweenShots = 10
	mode = Mode.AUTOMATIC

	ammo_left = ammoPerMag
	mags_left = 0

func _shoot():
	SoundManager.play_sound(Global.rng.randi_range(10, 13))
	spawn_bullet()
