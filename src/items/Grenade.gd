extends PickupableObject

const TIME_UNTIL_EXPLOSION: int = 5
const NUM_OF_BULLETS: int = 8
const BULLET_SPEED: int = 8
const BULLET_LIFESPAN: int = 10
const BULLET_DAMAGE: int = 100

var boom_scn = preload("res://scenes/gfx/OneShotAnimation.tscn")
var cotter_scn = preload("res://scenes/gfx/GrenadeCotter.tscn")
var bullet_scn = preload("res://scenes/projectiles/BreakBlocksBullet.tscn")

var used: bool = false

func _ready() -> void:
	throwVelocityModifiers = Vector2(4, 2)

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
	
func _flip_additional_parts() -> void:
	$Cotter.position.x = -$Cotter.position.x 

func spawn_bullets_in_circle() -> void:
	var points: Array = Util.calculate_points_in_circle(BULLET_SPEED, NUM_OF_BULLETS)
	for point in points:
		var bullet: KinematicBody2D = bullet_scn.instance()
		bullet.init(global_position, 
				Vector2(point.x * 20,
						point.y * 20),
				BULLET_LIFESPAN,
				BULLET_DAMAGE,
				world)
		world.add_child(bullet)

func drop_cotter() -> void:
	var cotter: Object = cotter_scn.instance()
	cotter.init($Cotter.global_position, holder.facing_right)
	world.add_child(cotter)

func spawn_explosion_gfx() -> void:
	var eff: AnimatedSprite = boom_scn.instance()
	eff.init(position, "explosion1")
	world.add_child(eff)

func destroy_blocks() -> void:
	var current_cell: Vector2 = world.world_to_map(position)
	var top_right_cell = Vector2(current_cell.x-1, current_cell.y-1)
	
	for i in 3:
		for j in 3:	
			world.set_cellv(Vector2(top_right_cell.x+i, top_right_cell.y+j), -1)
	
	world.update_bitmask_area(current_cell) # TODO, not sure if we want this. Depends on the final tilemap

func _on_ExplodeTimer_timeout() -> void:
	if holder:
		holder.picked_object = null
	
	SoundManager.play_sound(Util.rng.randi_range(0,1))
	spawn_explosion_gfx()
	spawn_bullets_in_circle()
	destroy_blocks()
	
	queue_free()

