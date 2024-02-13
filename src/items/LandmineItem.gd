extends PickupableObject

var mine_scn: PackedScene = preload("res://scenes/environment/Door.tscn")

func _use() -> void:
	var mine: Object = mine_scn.instance()
	mine.init()
	world.add_child(mine)
