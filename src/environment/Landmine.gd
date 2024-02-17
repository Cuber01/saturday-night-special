extends PickupableObject

extends PickupableObject

const TIME_UNTIL_EXPLOSION: int = 3
const NUM_OF_BULLETS: int = 8
const BULLET_SPEED: int = 8
const BULLET_LIFESPAN: int = 10
const BULLET_DAMAGE: int = 100

var mine_snc:   PackedScene = preload("res://scenes/environment/.tscn")
var cotter_scn: PackedScene = preload("res://scenes/gfx/GrenadeCotter.tscn")
var bullet_scn: PackedScene = preload("res://scenes/projectiles/Bullet.tscn")

var used: bool = false

func _ready() -> void:
	throwVelocity = Vector2(350, 200)

func _physics_process(delta: float) -> void:
	._physics_process(delta)
	if not holder:
		if velocity.x > 0:
			rotation += lerp(0, 2*PI, velocity.x/10000)
		elif velocity.x < 0:
			rotation += lerp(0, -2*PI, -velocity.x/10000)

func _use() -> void:
	if used:
		return
	
	used = true
	$Sprite.set_region_rect(Rect2(7,0,7,10))
	$ExplodeTimer.start(TIME_UNTIL_EXPLOSION)
	drop_cotter()

func _drop(throw_dir: Vector2) -> void:
	$Hitbox.set_deferred("disabled", false)
	$PickupZone.get_node("PickupZoneShape").set_deferred("disabled", false)
	
	velocity += Vector2(sign(throw_dir.x), -0.5) * throwVelocity
	holder = null

func _flip_additional_parts() -> void:
	$Cotter.position.x = -$Cotter.position.x 

func drop_cotter() -> void:
	var cotter: Object = cotter_scn.instance()
	cotter.init($Cotter.global_position, holder.facing_right)
	world.add_child(cotter)

func spawn_explosion_gfx() -> void:
	var eff: AnimatedSprite = boom_scn.instance()
	eff.init(position, "explosion1")
	world.add_child(eff)
	
func _on_ExplodeTimer_timeout() -> void:
	if holder:
		holder.picked_object = null
	
	SoundManager.play_sound(Util.rng.randi_range(0,1))
	spawn_explosion_gfx()
	Util.spawn_bullets_in_circle(NUM_OF_BULLETS, BULLET_SPEED, 
								BULLET_LIFESPAN, BULLET_DAMAGE, 
								world, global_position)
	
	queue_free()

