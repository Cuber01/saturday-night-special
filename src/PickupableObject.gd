extends KinematicBody2D
class_name PickupableObject

# Physics
const GRAVITY_FORCE: int = 200
const FRICTION_FORCE: float = 0.05 # Should take into account ground type / air in the future
const THROW_VELOCITY_MODIFIERS = Vector2(3, 1)

var velocity: Vector2 = Vector2()

var picked_up: bool = false
var facing_right: bool = false

func _physics_process(delta):
	
	if not picked_up:
		handle_gravity(delta)
		move()
		apply_friction()

func move() -> void:
	velocity = move_and_slide(velocity)

func flip_direction(dir_right: bool) -> void:
	if dir_right != facing_right:
		scale.x = scale.x * -1
		facing_right = not facing_right

func apply_friction() -> void:
	velocity.x = lerp(velocity.x, 0, FRICTION_FORCE)

func handle_gravity(delta) -> void:
	velocity.y += GRAVITY_FORCE * delta
	
func picked_update(newPos: Vector2) -> void:
	position = newPos

func _pick_up(player_dir_right: bool) -> void:
	$Hitbox.disabled = true
	$PickupZone.get_node("PickupZoneShape").disabled = true
	flip_direction(player_dir_right)
	picked_up = true
	
func _drop(throwVelocity: Vector2):
	$Hitbox.disabled = false
	$PickupZone.get_node("PickupZoneShape").disabled = false
	velocity += throwVelocity * THROW_VELOCITY_MODIFIERS
	picked_up = false
	
func _use():
	print( str(self) + "is being used!" )


