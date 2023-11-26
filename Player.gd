extends KinematicBody2D

export var snap := false
export var move_speed := 100
export var jump_force := 100
export var gravity := 200
export var slope_slide_threshold := 50.0

var is_in_air = true;
var velocity := Vector2()

func _physics_process(delta):
	var direction_x := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = direction_x * move_speed
	
	if Input.is_action_just_pressed("ui_accept") and snap:
		velocity.y = -jump_force
		snap = false
		is_in_air = true
	
	if is_in_air:
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	var snap_vector = Vector2(0, 32) if snap else Vector2()
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector2.UP, slope_slide_threshold, 4, deg2rad(46))
	
	var just_landed = not is_in_air and not snap
	if just_landed:
		snap = true	
		
	print(is_in_air)

func _on_IsOnFloor_body_entered(body):
	is_in_air = false

func _on_IsOnFloor_body_exited(body):
	is_in_air = true
