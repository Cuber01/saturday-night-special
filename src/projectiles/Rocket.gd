extends Bullet

const NUM_OF_BULLETS: int = 8
const BULLET_SPEED: int = 8
const BULLET_LIFESPAN: int = 10
const BULLET_DAMAGE: int = 100

onready var camera = world.get_parent().get_node("Camera")

var boom_scn = preload("res://scenes/gfx/OneShotAnimation.tscn")
var bullet_scn = preload("res://scenes/projectiles/Bullet.tscn")

func spawn_explosion_gfx() -> void:
	var eff: AnimatedSprite = boom_scn.instance()
	eff.init(position, "explosion1")
	world.add_child(eff)

func _collision_response(collision: KinematicCollision2D) -> bool:
	camera.add_trauma(0.8)
	SoundManager.play_sound(Global.rng.randi_range(0,1))
	spawn_explosion_gfx()
	Global.spawn_bullets_in_circle(NUM_OF_BULLETS, BULLET_SPEED, 
								BULLET_LIFESPAN, BULLET_DAMAGE, 
								world, global_position)
								
	
	queue_free()
	
	return false
