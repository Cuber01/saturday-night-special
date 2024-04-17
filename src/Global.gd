extends Node2D

const DAMAGE_KILL: int = 9999

enum DamageType {
	HURT,
	FREEZE
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
const GRAVITY_FORCE: int = 5

func calculate_points_in_circle(r: int, point_num: int):
	var points = []
	for i in point_num:
		points.append(Vector2(
							r*cos((i*2*PI)/point_num),
							r*sin((i*2*PI)/point_num)))
	return points

func spawn_bullets_in_circle(amount: int, speed: int, lifespan: int, 
							damage: int, world: Object, pos: Vector2) -> void:
	var bullet_scn = preload("res://scenes/projectiles/Bullet.tscn")
	var points: Array = Global.calculate_points_in_circle(speed, amount)
	for point in points:
		var bullet: KinematicBody2D = bullet_scn.instance()
		bullet.init(pos, 
				Vector2(point.x * 20,
						point.y * 20),
				lifespan,
				damage,
				world,
				true)
		world.call_deferred("add_child", bullet)
		
func positive_negative(num: float):
	if num > 0:
		return 1
	elif num < 0:
		return -1
	else:
		return 0
		

