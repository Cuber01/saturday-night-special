extends PickupableObject

const TIME_UNTIL_EXPLOSION = 5.0

func _use(user):
	$ExplodeTimer.start(TIME_UNTIL_EXPLOSION)
	throwVelocityModifiers = Vector2(5, 2)
	# drop fuse effect
	# change sprite

func _on_ExplodeTimer_timeout() -> void:
	# explode effects
	# spawn bullets
	
	var current_cell: Vector2 = world.world_to_map(position)
	
	for i in 3:
		for j in 3:	
			world.set_cellv(Vector2(current_cell.x+i, current_cell.y+j), -1)
	
	world.update_bitmask_area(current_cell) # TODO, not sure if we want this. Depends on the final tilemap


