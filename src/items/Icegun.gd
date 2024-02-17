extends BaseGun

func _ready() -> void:
	bulletScene = preload("res://scenes/projectiles/Snowball.tscn")
	bulletSpeed = 300
	bulletLifetime = 30
	bulletSpread = 0
	ammoPerMag = 10
	bulletDamage = 0
	recoilForce = Vector2(0,0)
	mode = Mode.MANUAL

	ammo_left = ammoPerMag
	mags_left = 0

func _shoot():
	spawn_bullet()
