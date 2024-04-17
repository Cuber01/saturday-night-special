extends BaseGun

func _ready() -> void:
	bulletScene = preload("res://scenes/projectiles/Snowball.tscn")
	bulletSpeed = 400
	bulletLifetime = 30
	bulletSpread = 0
	ammoPerMag = 10
	bulletDamage = 200
	recoilForce = Vector2(0,0)
	mode = Mode.MANUAL
	traumaOnShot = 0

	ammo_left = ammoPerMag
	mags_left = 0

func _shoot():
	SoundManager.play_sound(Global.rng.randi_range(17, 19))
	spawn_bullet()
