extends BaseGun

func _ready() -> void:
	bulletScene = preload("res://scenes/projectiles/Bullet.tscn")
	bulletSpeed = 500
	bulletLifetime = 20
	bulletSpread = 0.1
	ammoPerMag = 30
	bulletDamage = 5
	recoilForce = Vector2(200,-30)
	delayBetweenShots = 10
	mode = Mode.AUTOMATIC
	traumaOnShot = 0.2

	ammo_left = ammoPerMag
	mags_left = 0

func _shoot():
	SoundManager.play_sound(Global.rng.randi_range(10, 13))
	spawn_bullet()
