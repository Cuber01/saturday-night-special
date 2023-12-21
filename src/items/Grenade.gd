extends PickupableObject

const TIME_UNTIL_EXPLOSION = 5.0

var anim_scn = preload("res://scenes/gfx/OneShotAnimation.tscn")

func _ready() -> void:
	throwVelocityModifiers = Vector2(5, 2)

func _use() -> void:
	$Sprite.set_region_rect(Rect2(7,0,7,10))
	$ExplodeTimer.start(TIME_UNTIL_EXPLOSION)
	# drop fuse effect

func explosion_gfx() -> void:
	var eff: AnimatedSprite = anim_scn.instance()
	eff.init(position, "explosion1")
	world.add_child(eff)

func destroy_blocks() -> void:
	var current_cell: Vector2 = world.world_to_map(position)
	var top_right_cell = Vector2(current_cell.x-1, current_cell.y-1)
	
	for i in 3:
		for j in 3:	
			world.set_cellv(Vector2(top_right_cell.x+i, top_right_cell.y+j), -1)
	
	world.update_bitmask_area(current_cell) # TODO, not sure if we want this. Depends on the final tilemap

func _on_ExplodeTimer_timeout() -> void:
	holder.picked_object = null
	explosion_gfx()
	# spawn bullets
	destroy_blocks()
	
	queue_free()

