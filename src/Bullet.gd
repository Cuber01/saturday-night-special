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

func init(pos: Vector2, vel: Vector2) -> void:
	self.position = pos
	self.velocity = vel
	change_state(State.FLYING)

func _physics_process(delta):	
	match state:
		State.FLYING:
			flying(delta)
		State.DEATH_PHASE_1:
			death_phase_one(delta)
		State.DEATH_PHASE_2:
			death_phase_two()

func flying(delta):
	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)
	
	if collision_info != null:
		var colliding_body = collision_info.collider
		
		if colliding_body is Player:
			colliding_body.die()
			
		change_state(State.DEATH_PHASE_1)

func death_phase_one(delta) -> void:
	if death_counter <= 0:
		change_state(State.DEATH_PHASE_2)
		return
	
	move_and_collide(velocity * delta)
	death_counter -= 1
	
func death_phase_two():
	if  get_node_or_null("Trail") == null:
		queue_free()

func change_state(var new_state) -> void:
	match new_state:
		State.FLYING:
			continue
		State.DEATH_PHASE_1:
			remove_child($Sprite)
			remove_child($Hitbox)
		State.DEATH_PHASE_2:
			$Trail.stop()
		
	state = new_state

func die():
	queue_free()
