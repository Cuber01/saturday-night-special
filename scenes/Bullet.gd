extends KinematicBody2D

var velocity: Vector2
var trail: Trail

func _init(var velocity: Vector2):
	self.velocity = velocity
	trail = Trail.new()
	add_child(trail)

func _physics_process(delta):
	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)
	
	# if true then kill bullet and harm whatever we attacked
	
	pass
	
