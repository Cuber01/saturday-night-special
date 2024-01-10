extends KinematicBody2D
class_name Player

export var player_index: int = 0
export var facing_right: bool = true

# Sfx
var jump_sfx: Resource = preload("res://assets/audio/sfx/jump.wav")

# Movement
const SPEED: int = 100
const SLIDE_ADDED_SPEED: int = 150
const PUSH_FORCE: int = 10
const MAX_JUMP_HEIGHT: int = 50
const MIN_JUMP_HEIGHT: int = 5
const JUMP_DURATION = 0.5
var gravity: int = 2 * MAX_JUMP_HEIGHT / pow(JUMP_DURATION, 2)
var max_jump_velocity: int = -sqrt(2*gravity*MAX_JUMP_HEIGHT)
var min_jump_velocity: int = -sqrt(2*gravity*MIN_JUMP_HEIGHT)

const UP: Vector2 = Vector2(0, -1) # for move_and_slide and is_on_floor to choose what is considered floor

var velocity: Vector2 = Vector2()

# Collision
var hitbox_normal_extents: Vector2 = Vector2(19, 37.8)
var hitbox_normal_position: Vector2 = Vector2(4, -12.2)
var hitbox_normal_rotation: float = 0

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

# Pickup system vars
var picked_object: Object = null

# Other
var match_manager: Object
var dead: bool = false
var is_sliding: bool = false

signal sig_player_died(player_id)

func _ready() -> void:
	if not facing_right:
		flip_direction(true)
		
	set_color()
		
	match_manager = get_parent().get_parent()
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
			my_color = Color(255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0)
		1:
			my_color = Color(194.0/255.0, 27.0/255.0, 43.0/255.0, 1.0)
		2:
			my_color = Color(233.0/255.0, 86.0/255.0, 76.0/255.0, 1.0)
		3:
			my_color = Color(52.0/255.0, 61.0/255.0, 91.0/255.0, 1.0)
	
	mat_override.set_shader_param("new_color", my_color)
	$Sprite.set_material(mat_override)

func _physics_process(delta) -> void:	
	# Check for input and do certain actions
	input_move()
	input_jump()
	input_pickup()
	input_use()
	input_slide()
	input_go_down()
	
	# Handle Movement
	handle_gravity_force(delta)
	move_and_push()
	
	# Update held item
	# Saying just '$HoldItemPosition.position' gives us position in relation to parent (Player)
	if is_instance_valid(picked_object):
		picked_object.picked_update($HoldItemPosition.global_position)

# --------------------------- Movement

func input_move() -> void:
	var direction_x: float = 0
	direction_x = Input.get_action_strength(right_action) - Input.get_action_strength(left_action)
	
	if direction_x < 0:
		flip_direction(false)
	elif direction_x > 0:
		flip_direction(true)
	
	velocity.x = direction_x * SPEED

func flip_direction(dir_right: bool) -> void:
	if facing_right != dir_right:
		scale.x = scale.x * -1
		facing_right = not facing_right
		
		if is_instance_valid(picked_object):
			picked_object.flip_direction(dir_right)

func input_jump() -> void:
	if (Input.is_action_pressed(up_action) 
		and not Input.is_action_pressed(down_action)
		and is_on_floor()):			
			SoundManager.play_sound(2)
			velocity.y = max_jump_velocity
			
			if is_sliding:
				exit_slide()
			
	if Input.is_action_just_released(up_action) and velocity.y < min_jump_velocity:
		velocity.y = min_jump_velocity 

func input_go_down() -> void:
	if Input.is_action_pressed(down_action) and Input.is_action_pressed(up_action):
		position.y += 1

func input_slide() -> void:
	if Input.is_action_pressed(down_action) and is_on_floor():
		if velocity.x > 50:
			enter_slide()
			velocity.x += SLIDE_ADDED_SPEED
		elif velocity.x < -50:
			enter_slide()
			velocity.x -= SLIDE_ADDED_SPEED
			
	if is_sliding and Input.is_action_just_released(down_action):		
		exit_slide()
	
func handle_gravity_force(delta) -> void:
	velocity.y += Util.GRAVITY_FORCE * delta

func move_and_push() -> void:
	velocity = move_and_slide(velocity, UP)
	
	for i in get_slide_count():
		var col: KinematicCollision2D = get_slide_collision(i)
		if col.collider is Crate:
			col.collider.move_and_collide(Vector2(col.remainder.x, 0))
			col.collider.force_update_transform()
			
			move_and_collide(col.remainder)

# --------------------------- Sliding

func enter_slide() -> void:
	is_sliding = true
	$Hitbox.position = hitbox_slide_position
	$Hitbox.shape.extents = hitbox_slide_extents
	$Hitbox.rotation_degrees = hitbox_slide_rotation
	$Sprite.rotation_degrees = hitbox_slide_rotation
	
func exit_slide() -> void:
	is_sliding = false
	$Hitbox.position = hitbox_normal_position
	$Hitbox.shape.extents = hitbox_normal_extents
	$Hitbox.rotation_degrees = hitbox_normal_rotation
	$Sprite.rotation_degrees = hitbox_normal_rotation

# --------------------------- Item Management

func input_pickup() -> void:
	if Input.is_action_just_pressed(pickup_action):
		if picked_object == null:
			pickup_object()
		else:
			drop_object(velocity)

func input_use() -> void:
	if is_instance_valid(picked_object):
		if Input.is_action_pressed(use_action):
			picked_object._use()	
			
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

# --------------------------- Callbacks

func take_damage(damage: int) -> bool:
	if dead:
		return true
		
	dead = true
	emit_signal("sig_player_died", player_index)
	SoundManager.play_sound(7)
	match_manager.get_node("Camera").remove_target(self)
	queue_free()
	return true
