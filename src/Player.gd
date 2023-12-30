extends KinematicBody2D
class_name Player

export var player_index: int = 0
export var facing_right: bool = true

# Movement Constants
const SPEED: int = 100
const JUMP_FORCE: int = 200
const PUSH_FORCE: int = 10

const UP: Vector2 = Vector2(0, -1) # for move_and_slide and is_on_floor to choose what is considered floor

# Movement vars
var velocity: Vector2 = Vector2()

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
var match_manager

signal sig_player_died(player_id)

# We're preparing these for perforamance
func _ready() -> void:
	if not facing_right:
		flip_direction(true)
		
	set_color()
		
	match_manager = get_parent().get_parent()
# warning-ignore:return_value_discarded
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
	input_down()
	
	# Handle Movement
	handle_gravity_force(delta)
	move()
	
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
	if Input.is_action_pressed(up_action) and is_on_floor():
		velocity.y = -JUMP_FORCE

func input_down() -> void:
	if Input.is_action_pressed(down_action) and is_on_floor():
		position.y += 1

func handle_gravity_force(delta) -> void:
	velocity.y += Global.GRAVITY_FORCE * delta

func move() -> void:
	velocity = move_and_slide(velocity, UP)
	
	for i in get_slide_count():
		var col: KinematicCollision2D = get_slide_collision(i)
		if col.collider is Crate:
			col.collider.move_and_collide(Vector2(col.remainder.x, 0))
			col.collider.force_update_transform()
			
			move_and_collide(col.remainder)
	

# --------------------------- Item Management

func input_pickup() -> void:
	if Input.is_action_just_pressed(pickup_action):
		if picked_object == null:
			pickup_object()
		else:
			drop_object()

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

func drop_object() -> void:
	picked_object._drop(velocity)
	picked_object = null

# --------------------------- Callbacks

func take_damage(damage: int):
	emit_signal("sig_player_died", player_index)
	match_manager.get_node("Camera").remove_target(self)
	queue_free()

