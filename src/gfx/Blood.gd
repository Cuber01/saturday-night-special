extends Area2D

var is_colliding: bool = false

var vspeed: float = rand_range(-5, 5)
var hspeed: float
var blood_acc: float = rand_range(0.05, 0.1)
var do_wobble: float = false

var lifetime: float = rand_range(5,50)

onready var draw_surface: Object = get_parent()

func _physics_process(_delta: float) -> void:
	if is_colliding:
		draw_surface.draw_blood(global_position) 
		
		lifetime -= 1
		if(lifetime <= 0):
			 queue_free()
		
		if (vspeed > 3):
			 vspeed = 3
		vspeed = lerp(vspeed,0.1,blood_acc)
		
		#If we're moving downwards in a line, add wobble
		if(hspeed > 0.1 or hspeed < -0.1):
			hspeed = lerp(hspeed,0,0.1)
		else:
			do_wobble = true

		visible = false
	else: 
		do_wobble = false
		vspeed = lerp(vspeed, 5, 0.02)
		hspeed = lerp(hspeed, 0, 0.02)
		visible = true
		
	if(do_wobble):
		hspeed += rand_range(-0.01,0.01)
		hspeed = clamp(hspeed,-0.1,0.1)

	position.y += vspeed
	position.x += hspeed

func _on_Blood_body_entered(_body: Node) -> void:
	is_colliding = true

func _on_Blood_body_exited(_body: Node) -> void:
	is_colliding = false
