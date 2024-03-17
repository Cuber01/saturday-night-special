extends BaseGun

func _ready() -> void:
	bulletScene = preload("res://scenes/projectiles/Bullet.tscn")
	bulletSpeed = 500
	bulletLifetime = 80
	recoilForce = Vector2(100,-20)
	bulletSpread = 0
	bulletDamage = 10
	mode = Mode.MANUAL
	
	ammo_left = 6

func _shoot():
	SoundManager.play_sound(Global.rng.randi_range(10, 13))
	spawn_bullet()
