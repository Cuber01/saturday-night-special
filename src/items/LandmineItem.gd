extends PickupableObject

var mine_scn: PackedScene = preload("res://scenes/environment/Landmine.tscn")

const TIME_TIL_ARM: float = 3.0

func _use() -> void:
	var mine: Object = mine_scn.instance()
	mine.init(global_position, TIME_TIL_ARM)
	world.add_child(mine)
	holder.picked_object = null
	queue_free()
