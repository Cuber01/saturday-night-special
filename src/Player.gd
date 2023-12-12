extends KinematicBody2D
class_name Player

export var player_index: int = 1

# Movement Constants
const SPEED: int = 100
const JUMP_FORCE: int = 150
const GRAVITY_FORCE: int = 200

# Movement vars
var is_in_air: bool = true
var velocity: Vector2 = Vector2()
var facing_right: bool = true

# Action names
var right_action:  String
var left_action:   String
var up_action:     String
var down_action:   String
var pickup_action: String
var use_action:    String

# Pickup system vars
var picked_object: PickupableObject = null

# We're preparing these for perforamance
func _ready() -> void:
	right_action = "right_p" + str(player_index)
	left_action = "left_p" + str(player_index)
	up_action = "up_p" + str(player_index)
	down_action = "down_p" + str(player_index)
	pickup_action = "pickup_p" + str(player_index)
	use_action = "use_p" + str(player_index)

func _physics_process(delta) -> void:
	
	# Check for input and do certain actions
	input_move()
	input_jump()
	input_pickup()
	input_use()
	
	# Handle Movement
	handle_gravity_force(delta)
	move()
	
	# Update held item
	# Saying just '$HoldItemPosition.position' gives us position in relation to parent (Player)
	if picked_object != null:
		picked_object.picked_update($HoldItemPosition.global_position)

#########################################################################################
######### MOVEMENT ######################################################################
#########################################################################################

func input_move() -> void:
	var direction_x: int = 0
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
	if Input.is_action_pressed(up_action) and not is_in_air:
		velocity.y = -JUMP_FORCE
		is_in_air = true

func handle_gravity_force(delta) -> void:
	if is_in_air:
		velocity.y += GRAVITY_FORCE * delta
	else:
		velocity.y = 0

func move() -> void:
	velocity = move_and_slide(velocity)

#########################################################################################
########## ITEM MANAGEMENT ###########################################################
#########################################################################################

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

#########################################################################################
# EXTERNAL CALLBACK METHODS #############################################################
#########################################################################################

func die():
	queue_free()

func _on_IsOnFloor_body_entered(_body):
	is_in_air = false

func _on_IsOnFloor_body_exited(_body):
	is_in_air = true
