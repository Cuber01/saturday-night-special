extends KinematicBody2D

export var player_index: int = 1

# Movement Constants
const speed:        int = 100

const jump_force = 100
const gravity = 200

# Movement vars
var is_in_air: bool = true
var velocity: Vector2 = Vector2()

# Action names
var right_action: String
var left_action: String
var up_action: String
var down_action: String

# We're preparing these for perforamance
func _ready() -> void:
	right_action = "right_p" + str(player_index)
	left_action = "left_p" + str(player_index)
	up_action = "up_p" + str(player_index)
	down_action = "down_p" + str(player_index)

func _physics_process(delta) -> void:
	input_move()
	input_jump()
	handle_gravity(delta)
	move()

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


func _on_IsOnFloor_body_entered(body) -> void:
	is_in_air = false

func _on_IsOnFloor_body_exited(body) -> void:
	is_in_air = true

