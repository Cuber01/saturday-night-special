extends KinematicBody2D
class_name PickupableObject

# We spawn stuff here
var world: Object

enum Type {
		PISTOL,
		SHOTGUN,
		UZI,
		GRENADE,
		CRATE
	}

# Physics
const FRICTION_FORCE: float = 0.05 # Should take into account ground type / air in the future
var throwVelocityModifiers = Vector2(3, 1)
var velocity: Vector2 = Vector2()

# Pick up
signal sig_picked_up
var holder: Player = null

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
	if not holder:
		handle_gravity(delta)
		move()
		apply_friction()
	if can_despawn and not holder:
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
		position.x = -position.x
		$Sprite.flip_h = not $Sprite.flip_h
		_flip_additional_parts()
		facing_right = not facing_right

# Override
func _flip_additional_parts() -> void:
	pass

func apply_friction() -> void:
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, FRICTION_FORCE)
	else: 
		velocity.x = lerp(velocity.x, 0, FRICTION_FORCE/2)

func handle_gravity(delta) -> void:
	velocity.y += Global.GRAVITY_FORCE * delta
	
func picked_update(newPos: Vector2) -> void:
	position = newPos

# Override
func _pick_up(player: Player) -> void:
	$Hitbox.disabled = true
	$PickupZone.get_node("PickupZoneShape").disabled = true
	flip_direction(player.facing_right)
	rotation = 0
	holder = player
	emit_signal("sig_picked_up")

# Override
func _drop(throw_vel: Vector2) -> void:
	$Hitbox.disabled = false
	$PickupZone.get_node("PickupZoneShape").disabled = false
	velocity += throw_vel * throwVelocityModifiers
	holder = null

# Override
func _use() -> void:	
	push_error("_use(): No override")

func _on_DespawnTimer_timeout():
	if holder:
		can_despawn = true
	else:
		queue_free()
