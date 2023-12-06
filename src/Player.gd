extends KinematicBody2D

export var player_index: int = 1

# Movement Constants
const speed: int = 100
const jump_force: int = 150
const gravity: int = 200

# Movement vars
var is_in_air: bool = true
var velocity: Vector2 = Vector2()

# Action names
var right_action: String
var left_action: String
var up_action: String
var down_action: String
var pickup_action: String

# Pickup system vars
var picked_object: PickupableObject = null

# We're preparing these for perforamance
func _ready() -> void:
	right_action = "right_p" + str(player_index)
	left_action = "left_p" + str(player_index)
	up_action = "up_p" + str(player_index)
	down_action = "down_p" + str(player_index)
	pickup_action = "pickup_p" + str(player_index)

func _physics_process(delta) -> void:
	input_move()
	input_jump()
	input_pickup()
	handle_gravity(delta)
	move()
	
	# Saying just '$HoldItemPosition.position' gives us position in relation to parent (Player)
	if picked_object != null:
		picked_object.picked_update($HoldItemPosition.global_position)

func input_move() -> void:
	var direction_x: int = 0
	direction_x = Input.get_action_strength(right_action) - Input.get_action_strength(left_action)
	velocity.x = direction_x * speed

func input_jump() -> void:
	if Input.is_action_pressed(up_action) and not is_in_air:
		velocity.y = -jump_force
		is_in_air = true

func handle_gravity(delta) -> void:
	if is_in_air:
		velocity.y += gravity * delta
	else:
		velocity.y = 0

func move() -> void:
	velocity = move_and_slide(velocity)

func input_pickup() -> void:
	if Input.is_action_just_pressed(pickup_action):
		if picked_object == null:
			pickup_object()
		else:
			drop_object()

func pickup_object() -> void:
	var objects: Array = $PickupZone.get_overlapping_areas()
	
	if objects.size() != 0:
		var item: PickupableObject = objects[0].owner
		item._pick_up()
		picked_object = item

func drop_object() -> void:
	picked_object._drop()
	picked_object = null

func _on_IsOnFloor_body_entered(_body):
	is_in_air = false

func _on_IsOnFloor_body_exited(_body):
	is_in_air = true
