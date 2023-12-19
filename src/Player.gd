extends KinematicBody2D
class_name Player

export var player_index: int = 0
export var facing_right: bool = true

# Movement Constants
const SPEED: int = 100
const JUMP_FORCE: int = 200
const GRAVITY_FORCE: int = 275

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
var picked_object: PickupableObject = null

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
	if picked_object != null:
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
		
		if picked_object != null:
			picked_object.flip_direction(dir_right)

func input_jump() -> void:
	if Input.is_action_pressed(up_action) and is_on_floor():
		velocity.y = -JUMP_FORCE

func input_down() -> void:
	if Input.is_action_pressed(down_action) and is_on_floor():
		position.y += 1

func handle_gravity_force(delta) -> void:
	velocity.y += GRAVITY_FORCE * delta

func move() -> void:
	velocity = move_and_slide(velocity, UP)

# --------------------------- Item Management

func input_pickup() -> void:
	if Input.is_action_just_pressed(pickup_action):
		if picked_object == null:
			pickup_object()
		else:
			drop_object()

func input_use() -> void:
	if Input.is_action_just_pressed(use_action):
		if picked_object != null:
			picked_object._use(self)

func pickup_object() -> void:
	var objects: Array = $PickupZone.get_overlapping_areas()
	
	if objects.size() != 0:
		var item: PickupableObject = objects[0].owner
		item._pick_up(facing_right)
		picked_object = item

func drop_object() -> void:
	picked_object._drop(velocity)
	picked_object = null

# --------------------------- Callbacks

func die():
	emit_signal("sig_player_died", player_index)
	match_manager.get_node("Camera").remove_target(self)
	queue_free()

