extends KinematicBody2D
class_name Bullet

var spark_gfx = preload("res://scenes/gfx/particles/Spark.tscn")

enum State {
	FLYING, 
	DEATH_PHASE_1, # We have collided, but we have to wait for the trail to get closer to the wall
	DEATH_PHASE_2  # We are waiting for the trail to dissappear
}

var velocity: Vector2
var state = -1
var death_counter: int = 1	

var world: TileMap
var lifetime: int
var damage: int

func init(pos: Vector2, vel: Vector2, lifespan: int,
		  damage: int,	 world: TileMap) -> void:
	self.position = pos
	self.velocity = vel
	self.lifetime = lifespan
	self.damage = damage
	self.world = world
	change_state(State.FLYING)

func _physics_process(delta):		
	match state:
		State.FLYING:
			flying(delta)
		State.DEATH_PHASE_1:
			death_phase_one(delta)
		State.DEATH_PHASE_2:
			death_phase_two()

func flying(delta: float) -> void:
	if check_lifetime(): 
		change_state(State.DEATH_PHASE_1)
		return
	if not fly_or_collide(delta):
		change_state(State.DEATH_PHASE_1)


func fly_or_collide(delta: float) -> bool:
	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)
	
	if collision_info != null:
		var pierce: bool = collision_response(collision_info)
		return pierce
		
	return true

func spawn_spark_gfx() -> void:
	var eff: Object = spark_gfx.instance()
	eff.global_position = self.global_position
	world.add_child(eff)

func collision_response(collision: KinematicCollision2D) -> bool:
	var colliding_body = collision.collider
	
	if colliding_body.has_method("take_damage"):
		return colliding_body.take_damage(damage) 
	elif colliding_body.name == "BasicTilemap":
		var cell: Vector2 = world.world_to_map(collision.position - collision.normal)
		return world.damage_tile(world, world.main_map, cell, damage)
		
	return false
	
func check_lifetime() -> bool:
	if lifetime <= 0:
		return true
	elif state == State.FLYING:
		lifetime -= 1
	return false

func death_phase_one(delta) -> void:
	if death_counter <= 0:
		change_state(State.DEATH_PHASE_2)
		return
	
# warning-ignore:return_value_discarded
	move_and_collide(velocity * delta)
	death_counter -= 1
	
func death_phase_two():
	if get_node_or_null("Trail") == null:
		die()

func change_state(var new_state) -> void:
	match new_state:
		State.FLYING:
			continue
		State.DEATH_PHASE_1:
			spawn_spark_gfx()
			remove_child($Hitbox)
		State.DEATH_PHASE_2:
			$Trail.stop()
		
	state = new_state

func die():
	queue_free()
