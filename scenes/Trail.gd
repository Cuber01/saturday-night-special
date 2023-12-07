extends Line2D
class_name Trail

onready var curve := Curve2D.new() 

const max_points: int = 100

func _process(delta) -> void:
	curve.add_point(get_parent().position)
	if	curve.get_baked_points().size() > max_points:
		curve.remove_point(0)
	points = curve.get_baked_points()
	
func stop() -> void:
	set_process(false)
	var tw := get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 3.0)
	
	yield(tw, "finished")
	
	queue_free()
	
