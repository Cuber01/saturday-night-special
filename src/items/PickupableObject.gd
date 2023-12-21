extends KinematicBody2D
class_name PickupableObject

# We spawn stuff here
var world: Object

enum Type {
		PISTOL,
		SHOTGUN,
		UZI
	}

# Physics
const FRICTION_FORCE: float = 0.05 # Should take into account ground type / air in the future
var throwVelocityModifiers = Vector2(3, 1)
var velocity: Vector2 = Vector2()

# Pick up
signal sig_picked_up
var picked_up: bool = false

# Despawn
var can_despawn: bool = false
const TIME_UNTIL_DESPAWN: float = 5.0

# Other
var facing_right: bool = false
var button_released: bool = false

func _ready() -> void:
	world = get_parent()

# Remember: this doesn't get called automatically
func init(pos: Vector2, spawner_mother: Object) -> void:
	global_position = pos
	connect("sig_picked_up", spawner_mother, "_on_weapon_picked_up")

func _physics_process(delta) -> void:
	if not picked_up:
		handle_gravity(delta)
		move()
		apply_friction()
	if can_despawn and not picked_up:
		$DespawnTimer.start(TIME_UNTIL_DESPAWN)
		can_despawn = false # avoid resetting the timer
		
	_overriden_update()	

# Override
func _overriden_update() -> void:
	pass

func move() -> void:
	velocity = move_and_slide(velocity)

func flip_direction(dir_right: bool) -> void:
	if dir_right != facing_right:
		scale.x = scale.x * -1
		facing_right = not facing_right

func apply_friction() -> void:
	velocity.x = lerp(velocity.x, 0, FRICTION_FORCE)

func handle_gravity(delta) -> void:
	velocity.y += Global.GRAVITY_FORCE * delta
	
func picked_update(newPos: Vector2) -> void:
	position = newPos

func pick_up(player_dir_right: bool) -> void:
	$Hitbox.disabled = true
	$PickupZone.get_node("PickupZoneShape").disabled = true
	flip_direction(player_dir_right)
	picked_up = true
	emit_signal("sig_picked_up")
	
func drop(throw_vel: Vector2) -> void:
	$Hitbox.disabled = false
	$PickupZone.get_node("PickupZoneShape").disabled = false
	velocity += throw_vel * throwVelocityModifiers
	picked_up = false

# Override
func _use(user) -> void:	
	push_error("_use(): No override")

func _on_DespawnTimer_timeout():
	if picked_up:
		can_despawn = true
		return
	queue_free()
