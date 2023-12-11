extends KinematicBody2D
class_name Bullet

var velocity: Vector2
var trail: Trail

func init(pos: Vector2, vel: Vector2) -> void:
	self.position = pos
	self.velocity = vel
	trail = Trail.new()
	add_child(trail)
	pass

func _physics_process(delta):
	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)
	
	# if true then kill bullet and harm whatever we attacked
	
	pass
	
