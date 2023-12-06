extends KinematicBody2D

class_name PickupableObject

const gravity_force: int = 200
var velocity: Vector2 = Vector2()

var picked_up: bool = false

func _physics_process(delta):
	
	if not picked_up:
		handle_gravity(delta)
		move()

func move() -> void:
	velocity = move_and_slide(velocity)

func handle_gravity(delta) -> void:
	velocity.y += gravity_force * delta
	
func picked_update(newPos: Vector2) -> void:
	position = newPos

func _pick_up() -> void:
	$FloorCollisionShape.disabled = true
	$PickupZone.get_node("PickupZoneShape").disabled = true
	picked_up = true
	
func _drop():
	$FloorCollisionShape.disabled = false
	$PickupZone.get_node("PickupZoneShape").disabled = false
	picked_up = false
	
func _use():
	print( str(self) + "is being used!" )


