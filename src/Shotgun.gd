extends BaseGun

const BULLETS_PER_SHOT = 8

func _ready() -> void:
	bulletScene = preload("res://scenes/projectiles/Bullet.tscn")
	bulletSpeed = 120
	bulletLifetime = 30
	bulletSpread = 10.0
	ammoPerMag = 1
	reloadTime = 3
	recoilForce = Vector2(300,-60)
	mode = Mode.MANUAL
	
	ammo_left = ammoPerMag
	mags_left = 3

func _shoot():
	for i in BULLETS_PER_SHOT:
		spawn_bullet()
