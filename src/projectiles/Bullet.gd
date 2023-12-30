extends KinematicBody2D
class_name Bullet

enum State {
	FLYING, 
	DEATH_PHASE_1, # We have collided, but we have to wait for the trail to get closer to the wall
	DEATH_PHASE_2  # We are waiting for the trail to dissappear
}

var velocity: Vector2
var state = -1
var death_counter: int = 1	

var lifetime: int
var damage: int

func init(pos: Vector2, vel: Vector2, lifespan: int,
		  damage: int,	 world: TileMap = null) -> void:
	self.position = pos
	self.velocity = vel
	self.lifetime = lifespan
	self.damage = damage
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
	if fly_or_collide(delta):
		change_state(State.DEATH_PHASE_1)


func fly_or_collide(delta: float) -> bool:
	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)
	
	if collision_info != null:
		collision_response(collision_info)
		return true
		
	return false

func collision_response(collision: KinematicCollision2D) -> void:
	var colliding_body = collision.collider
	
	if colliding_body.has_method("take_damage"):
		colliding_body.take_damage(damage)

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
		queue_free()

func change_state(var new_state) -> void:
	match new_state:
		State.FLYING:
			continue
		State.DEATH_PHASE_1:
			remove_child($Hitbox)
		State.DEATH_PHASE_2:
			$Trail.stop()
		
	state = new_state

func die():
	queue_free()
