extends BaseGun

func _ready() -> void:
	bulletScene = preload("res://scenes/projectiles/Bullet.tscn")
	bulletSpeed = 120
	bulletLifetime = 100
	recoilForce = Vector2(100,-20)
	bulletSpread = 1.0
	mode = Mode.MANUAL
	
	ammo_left = 6


func _shoot():
	spawn_bullet()
