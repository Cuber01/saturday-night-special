extends KinematicBody2D

class_name PickupableObject

const gravity_force: int = 200
var velocity: Vector2 = Vector2()

func _physics_process(delta):
	
	handle_gravity(delta)
	move()
	
	if _picked_up():
		pass

func move() -> void:
	velocity = move_and_slide(velocity)

func _picked_up() -> bool:
	return false
	
func _use():
	print( str(self) + "is being used!" )
	
func _drop():
	pass

func handle_gravity(delta) -> void:
	velocity.y += gravity_force * delta
