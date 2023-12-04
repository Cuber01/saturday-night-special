extends KinematicBody2D

class_name PickupableObject

onready var is_on_floor = $IsOnFloor

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
	if not is_on_floor.colliding():
		velocity.y += gravity_force * delta
	else:
		velocity.y = 0
		
