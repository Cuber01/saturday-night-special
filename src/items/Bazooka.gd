extends BaseGun

func _ready() -> void:
	bulletScene = preload("res://scenes/projectiles/Rocket.tscn")
	bulletSpeed = 300
	bulletLifetime = 999
	bulletSpread = 0
	bulletDamage = 100
	ammo_left = 3
	recoilForce = Vector2(400,-60)
	mode = Mode.MANUAL

func _shoot():
	SoundManager.play_sound(14)
	spawn_bullet()
