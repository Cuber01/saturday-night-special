extends KinematicBody2D

class_name PickupableObject

# Physics
const gravity_force: int = 200
const friction_force: float = 0.05 # Should take into account ground type / air in the future
const throwVelocityModifiers = Vector2(3, 1)

var velocity: Vector2 = Vector2()

var picked_up: bool = false

func _physics_process(delta):
	
	if not picked_up:
		handle_gravity(delta)
		move()
		apply_friction()

func move() -> void:
	velocity = move_and_slide(velocity)

func apply_friction() -> void:
	velocity.x = lerp(velocity.x, 0, friction_force)

func handle_gravity(delta) -> void:
	velocity.y += gravity_force * delta
	
func picked_update(newPos: Vector2) -> void:
	position = newPos

func _pick_up() -> void:
	$CollisionShape2D.disabled = true
	$PickupZone.get_node("PickupZoneShape").disabled = true
	picked_up = true
	
func _drop(throwVelocity: Vector2):
	$CollisionShape2D.disabled = false
	$PickupZone.get_node("PickupZoneShape").disabled = false
	velocity += throwVelocity * throwVelocityModifiers
	picked_up = false
	
func _use():
	print( str(self) + "is being used!" )


