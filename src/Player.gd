extends KinematicBody2D
class_name Player

export var player_index: int = 0
export var facing_right: bool = true

# Sfx
var jump_sfx: Resource = preload("res://assets/audio/sfx/jump.wav")
var blood_gfx: Resource = preload("res://scenes/gfx/particles/Blood.tscn")
var dynamic_blood: Resource = preload("res://scenes/gfx/DynamicBlood.tscn")
var guts_gfx: Resource = preload("res://scenes/gfx/particles/Guts.tscn")
var ice_break_gfx: Resource = preload("res://scenes/gfx/particles/IceBreak.tscn")

# Movement
const SPEED: int = 75
const NORMAL_FRICTION_FORCE: float = 0.22
const FROZEN_FRICTION_FORCE: float = 0.001
const SLIDING_FRICTION_FORCE: float = 0.10
const MIN_SLIDE_EXIT_VELOCITY: int = 15

const MAX_JUMP_HEIGHT: int = 75
const MIN_JUMP_HEIGHT: int = 5
const JUMP_DURATION = 0.5
var gravity: int = 2 * MAX_JUMP_HEIGHT / pow(JUMP_DURATION, 2)
var max_jump_velocity: int = -sqrt(2*gravity*MAX_JUMP_HEIGHT)
var min_jump_velocity: int = -sqrt(2*gravity*MIN_JUMP_HEIGHT)

const UP: Vector2 = Vector2(0, -1) # for move_and_slide and is_on_floor to choose what is considered floor

var velocity: Vector2 = Vector2()

# Collision
var hitbox_standing_extents: Vector2 = Vector2(19, 37.8)
var hitbox_standing_position: Vector2 = Vector2(4, -12.2)
var hitbox_standing_rotation: float = 0

var hitbox_slide_extents: Vector2 = Vector2(19, 37.8)
var hitbox_slide_position: Vector2 = Vector2(4.267, 7.3)
var hitbox_slide_rotation: float = 90

# Action names
var right_action:  String
var left_action:   String
var up_action:     String
var down_action:   String
var pickup_action: String
var use_action:    String

# State
var is_dead: bool = false
var is_sliding: bool = false
var can_pickup: bool = true
var picked_object: Object = null
var freeze_hitpoints: int = FREEZE_HP_WARMED
var is_frozen: bool = false
var current_friction: float = NORMAL_FRICTION_FORCE

# Other
const MAX_FREEZE_HP: int = 800
const FREEZE_HP_WARMED: int = -210
const FREEZE_DECAY: int = 1
const VOID_Y: int = 700 # Player dies when reaching this coordinate
onready var match_manager: Object = get_parent().get_parent()
var moved_last_frame: bool = false

signal sig_player_died(player_id)

onready var world = get_parent()
onready var surface = world.get_parent().get_node("Surface")

func _ready() -> void:
	set_color()
	
	if not facing_right:
		scale.x = scale.x * -1
		
	connect("sig_player_died", match_manager, "_on_player_died")
	match_manager.get_node("Camera").add_target(self)
	
	right_action = "right_p" + str(player_index)
	left_action = "left_p" + str(player_index)
	up_action = "up_p" + str(player_index)
	down_action = "down_p" + str(player_index)
	pickup_action = "pickup_p" + str(player_index)
	use_action = "use_p" + str(player_index)

func set_color() -> void:
	var mat_override: Material = $Sprite.get_material().duplicate()
	var my_color: Color
	
	match player_index:
		0:
			my_color = Color(249.0/255.0, 130.0/255.0, 132.0/255.0, 1.0)
		1:
			my_color = Color(176.0/255.0, 235.0/255.0, 147.0/255.0, 1.0)
		2:
			my_color = Color(233.0/255.0, 86.0/255.0, 76.0/255.0, 1.0)
		3:
			my_color = Color(52.0/255.0, 61.0/255.0, 91.0/255.0, 1.0)
	
	mat_override.set_shader_param("new_color", my_color)
	$Sprite.set_material(mat_override)

func _physics_process(delta) -> void:	
	
	if position.y >= VOID_Y:
		take_damage(Global.DAMAGE_KILL) # Player dies when falling into void
	
	# Check for input and do certain actions
	if not is_frozen:
		input_move()
		input_jump()
		input_pickup()
		input_use()
		input_slide()
		input_go_down()
	else:
		frozen_update()
	
	# Handle Movement
	handle_gravity_force(delta)
	apply_friction()
	slide_update()
	move_and_push()
	
	# Update held item
	# Saying just '$HoldItemPosition.position' gives us position in relation to parent (Player)
	if is_instance_valid(picked_object):
		picked_object.picked_update($HoldItemPosition.global_position)

# --------------------------- Movement

func input_move() -> void:
	var direction_x: float = 0
	direction_x = Input.get_action_strength(right_action) - Input.get_action_strength(left_action)
	
	if direction_x != 0 and not moved_last_frame:
			play_animation("move")
	
	if direction_x == 0:
		moved_last_frame = false
	else:
		moved_last_frame = true
			
	if direction_x < 0:
		flip_direction(false)
	elif direction_x > 0:
		flip_direction(true)
		
	
	velocity.x += direction_x * SPEED

func input_jump() -> void:
	if (Input.is_action_pressed(up_action) 
		and not Input.is_action_pressed(down_action)
		and is_on_floor()):			
			SoundManager.play_sound(2)
			play_animation("jump")
			velocity.y = max_jump_velocity
			
			if is_sliding:
				exit_slide()
			
	if Input.is_action_just_released(up_action) and velocity.y < min_jump_velocity:
		velocity.y = min_jump_velocity 

func input_go_down() -> void:
	if Input.is_action_pressed(down_action) and Input.is_action_pressed(up_action):
		position.y += 1

func input_slide() -> void:
	if not is_sliding and Input.is_action_pressed(down_action) and is_on_floor():
		if velocity.x > 50:
			enter_slide()
		elif velocity.x < -50:
			enter_slide()
			
	if is_sliding and Input.is_action_just_released(down_action):		
		exit_slide()

func apply_friction() -> void:
	velocity.x = lerp(velocity.x, 0, current_friction)

func flip_direction(dir_right: bool) -> void:
	if facing_right != dir_right:
		scale.x = scale.x * -1
		facing_right = not facing_right
		
		if is_instance_valid(picked_object):
			picked_object.flip_direction(dir_right)

func handle_gravity_force(delta) -> void:
	velocity.y += gravity * delta

func move_and_push() -> void:
	velocity = move_and_slide(velocity, UP)
	
	for i in get_slide_count():
		var col: KinematicCollision2D = get_slide_collision(i)
		if col.collider is Crate:
			col.collider.move_and_collide(Vector2(col.remainder.x, 0))
			col.collider.force_update_transform()
			
			move_and_collide(col.remainder)
		elif col.collider.has_method("get_pushed"):
			col.collider.get_pushed(Vector2(col.remainder.x, 0))

# --------------------------- Sliding

func slide_update() -> void:
	if is_sliding and abs(velocity.x) < MIN_SLIDE_EXIT_VELOCITY:
		exit_slide()

func enter_slide() -> void:
	var col: Array = $SlideArea.get_overlapping_bodies()
	if col:
		# Unable to slide — there's not enough space
		return
	
	drop_object(velocity.snapped(Vector2(1,1)))
	
	current_friction = SLIDING_FRICTION_FORCE
	is_sliding = true
	$Hitbox.position = hitbox_slide_position
	$Hitbox.shape.extents = hitbox_slide_extents
	$Hitbox.rotation_degrees = hitbox_slide_rotation
	$Sprite.rotation_degrees = hitbox_slide_rotation
	can_pickup = false
	
func exit_slide() -> void:
	var col: Array = $StandingArea.get_overlapping_bodies()
	if col:
		# Unable to get up — there's not enough space
		return
	
	current_friction = NORMAL_FRICTION_FORCE
	is_sliding = false
	$Hitbox.position = hitbox_standing_position
	$Hitbox.shape.extents = hitbox_standing_extents
	$Hitbox.rotation_degrees = hitbox_standing_rotation
	$Sprite.rotation_degrees = hitbox_standing_rotation
	can_pickup = true

# --------------------------- Item Management

func input_pickup() -> void:
	if can_pickup and Input.is_action_just_pressed(pickup_action):
		if picked_object == null:
			pickup_object()
		else:
			drop_object(velocity.snapped(Vector2(1,1)))

func input_use() -> void:
	if is_instance_valid(picked_object):
		if Input.is_action_pressed(use_action):
			picked_object._use()	
			
	if is_instance_valid(picked_object):
		if Input.is_action_just_released(use_action):
			picked_object.button_released = true
		else:
			picked_object.button_released = false

func pickup_object() -> void:
	var objects: Array = $PickupZone.get_overlapping_areas()
	
	for obj in objects:
		var item: Object = obj.owner
		if item is PickupableObject:
			item._pick_up(self)
			picked_object = item
			break

func drop_object(vel: Vector2) -> void:
	if picked_object:
		picked_object._drop(vel)
		picked_object = null

# --------------------------- Death and Freezing

func die(dir: Vector2 = Vector2(0,-1)) -> void:
	is_dead = true
	
	if is_frozen:
		spawn_death_particle(ice_break_gfx, Vector2(0,-1))
	else:	
		spawn_death_particle(guts_gfx, dir)
		spawn_death_particle(blood_gfx, dir)
		spawn_dynamic_blood(120, dir)
		
	drop_object(velocity)
	emit_signal("sig_player_died", player_index)
	SoundManager.play_sound(24)
	match_manager.get_node("Camera").remove_target(self)
	queue_free()

func spawn_death_particle(particles: Object, dir: Vector2):
	var eff: Object = particles.instance() 
	eff.process_material.set("direction", Vector3(dir.x, dir.y, 0))
	eff.global_position = Vector2(self.global_position.x, self.global_position.y)
	world.add_child(eff)

func spawn_dynamic_blood(amount: int, dir: Vector2):
	for i in range(amount):
			var blood_instance = dynamic_blood.instance()
			
			if dir.x < 0:
				blood_instance.hspeed = rand_range(-3,1)
			else:
				blood_instance.hspeed = rand_range(-1, 3)
				
			blood_instance.global_position = self.global_position
			surface.call_deferred("add_child", blood_instance)

func get_pushed(push_factor: Vector2):
	velocity.x += push_factor.x * 80

func freeze() -> void:
	SoundManager.play_sound(20)
	$FreezeEffect.visible = true
	set_collision_layer_bit(4, true)
	drop_object(velocity)
	current_friction = FROZEN_FRICTION_FORCE
	is_frozen = true
	
func unfreeze() -> void:
	SoundManager.play_sound(22)
	$FreezeEffect.visible = false
	set_collision_layer_bit(4, false)
	current_friction = NORMAL_FRICTION_FORCE
	is_frozen = false

func frozen_update() -> void:
	freeze_hitpoints -= FREEZE_DECAY
	
	if freeze_hitpoints <= 0:
		freeze_hitpoints = FREEZE_HP_WARMED
		unfreeze() 

func take_freeze_dmg(freeze_points: int) -> void:
	freeze_hitpoints += freeze_points
	
	if is_frozen:
		if freeze_hitpoints > MAX_FREEZE_HP:
			freeze_hitpoints = MAX_FREEZE_HP
	else:
		if freeze_hitpoints > 0 and not is_frozen:
			freeze()

# --------------------------- Animation

func play_animation(name: String) -> void:
	$Sprite.stop()
	$Sprite.frame = 0
	$Sprite.play(name)

# --------------------------- Callbacks

func take_damage(damage: int,
				 damage_type: int = Global.DamageType.HURT,
				 direction: Vector2 = Vector2(0,-1)) -> bool:
	if is_dead:
		return true
	
	if damage_type == Global.DamageType.HURT:
		die(direction)
		return true
	elif damage_type == Global.DamageType.FREEZE:
		take_freeze_dmg(damage)
		return false
		
	return false

func _on_PlayerDetection_body_entered(body: Node) -> void:
	if body.is_sliding:
		body.drop_object(body.velocity)
