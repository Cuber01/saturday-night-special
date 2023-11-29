extends KinematicBody2D

export var player_index = 1;

var move_speed = 100
var acceleration = 30
var friction = 50;

var jump_force = 100
var gravity = 200
var slope_slide_threshold = 50.0

var direction_x = 0;

var is_in_air = true;
var velocity := Vector2()

var right_action
var left_action
var up_action
var down_action

# performance
func _ready():
	right_action = "right_p" + str(player_index)
	left_action = "left_p" + str(player_index)
	up_action = "up_p" + str(player_index)
	down_action = "down_p" + str(player_index)

func _physics_process(delta):
	direction_x = Input.get_action_strength(right_action) - Input.get_action_strength(left_action)
	velocity.x = direction_x * move_speed

	if Input.is_action_pressed(up_action) and not is_in_air:
		velocity.y = -jump_force
		is_in_air = true

	if is_in_air:
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	velocity = move_and_slide(velocity)
	direction_x = 0;

func _on_IsOnFloor_body_entered(body):
	is_in_air = false

func _on_IsOnFloor_body_exited(body):
	is_in_air = true

