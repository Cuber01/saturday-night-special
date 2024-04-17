extends KinematicBody2D
class_name PickupableObject

var despawn_gfx: Resource = preload("res://scenes/gfx/particles/Smoke.tscn")

# We spawn stuff here
var world: Object

enum Type {
		PISTOL,
		SHOTGUN,
		UZI,
		GRENADE,
		CRATE,
		BAZOOKA,
		LANDMINE,
		ICE_GUN
	}

# Physics
const FRICTION_FORCE: float = 0.07 # Should take into account ground type / air in the future
var throwVelocity = Vector2(200, 100)
var velocity: Vector2 = Vector2()

# Pick up
signal sig_picked_up
var holder: Object = null

# Despawn
var can_despawn: bool = false
const TIME_UNTIL_DESPAWN: float = 5.0

# Other
var facing_right: bool = true
var button_released: bool = false
var levitating: bool = false

func _ready() -> void:
	world = get_parent()

# Remember: this doesn't get called automatically
func init(pos: Vector2, spawner_mother: Object) -> void:
	global_position = pos
	levitating = true # Only if spawned by a spawner
	connect("sig_picked_up", spawner_mother, "_on_weapon_picked_up")

# Override
func _physics_process(delta) -> void:
	if not holder:
		handle_gravity()
		move()
		apply_friction()
	if can_despawn and not holder:
		$DespawnTimer.start(TIME_UNTIL_DESPAWN)
		can_despawn = false # avoid resetting the timer

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

func handle_gravity() -> void:
	if not levitating:
		velocity.y += Global.GRAVITY_FORCE
	
func picked_update(newPos: Vector2) -> void:
	position = newPos

# Override
func _pick_up(player: Object) -> void:
	$Hitbox.disabled = true
	$PickupZone.get_node("PickupZoneShape").disabled = true
	flip_direction(player.facing_right)
	rotation = 0
	levitating = false
	holder = player
	emit_signal("sig_picked_up")

# Override
func _drop(throw_dir: Vector2) -> void:
	$Hitbox.set_deferred("disabled", false)
	$PickupZone.get_node("PickupZoneShape").set_deferred("disabled", false)
		
	velocity += Vector2(sign(throw_dir.x), sign(throw_dir.y)) * throwVelocity
	holder = null

# Override
func _use() -> void:	
	push_error("_use(): No override")

func _on_DespawnTimer_timeout():
	if holder != null:
		can_despawn = true
	else:
		var eff: Object = despawn_gfx.instance()
		eff.global_position = self.global_position
		world.add_child(eff)
		queue_free()
