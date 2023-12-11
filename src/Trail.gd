extends Line2D
class_name Trail

var length: int
var point: Vector2

func _init(length = 50) -> void:
	self.length = length

func _process(_delta) -> void:
	global_position = Vector2(0,0)
	
	point = get_parent().global_position
	
	add_point(point)
	while get_point_count() > length:
		remove_point(0)

func stop() -> void:
	set_process(false)
	var tw := get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 3.0)
	
	yield(tw, "finished")
	
	queue_free()
	
