extends KinematicBody2D

const NUM_OF_BULLETS: int = 8
const BULLET_SPEED: int = 8
const BULLET_LIFESPAN: int = 10
const BULLET_DAMAGE: int = 100

onready var world: Object = get_parent()
onready var camera: Object = world.get_parent().get_node("Camera")

var boom_scn:   PackedScene = preload("res://scenes/gfx/OneShotAnimation.tscn")
var bullet_scn: PackedScene = preload("res://scenes/projectiles/Bullet.tscn")

var ArmedTimer: Timer
var is_armed: bool = true
var velocity: Vector2

func init(pos: Vector2, time_til_arm: float):
	global_position = pos
	
	$Sprite.set_region_rect(Rect2(14,0,14,7))
	
	is_armed = false
	ArmedTimer = Timer.new()
	ArmedTimer.autostart = true
	ArmedTimer.one_shot = true
	ArmedTimer.wait_time = time_til_arm
	ArmedTimer.connect("timeout", self, "_on_ArmedTimer_timeout")
	add_child(ArmedTimer)
	
func _physics_process(delta: float) -> void:
	velocity.y += Global.GRAVITY_FORCE
	velocity = move_and_slide(velocity)

func spawn_explosion_gfx() -> void:
	var eff: AnimatedSprite = boom_scn.instance()
	eff.init(position, "explosion1")
	world.add_child(eff)
	
func _on_DetectionArea_body_entered(body: Node) -> void:
	if not is_armed or body == self:
		return
	
	SoundManager.play_sound(Global.rng.randi_range(0,1))
	spawn_explosion_gfx()
	camera.add_trauma(0.8)
	Global.spawn_bullets_in_circle(NUM_OF_BULLETS, BULLET_SPEED, 
								BULLET_LIFESPAN, BULLET_DAMAGE, 
								world, Vector2(global_position.x, global_position.y+5)) # The +5 is to fix a very specific collision bug that resulted in all bullets spawning inside the ground while the player was somehow pushing the mine into the ground
	
	queue_free()

func _on_ArmedTimer_timeout() -> void:
	$Sprite.set_region_rect(Rect2(0,0,14,7))
	SoundManager.play_sound(23)
	is_armed = true
