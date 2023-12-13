extends Line2D
class_name Trail

var current_point: Vector2
const time_to_dissappear: float = 0.5

export var length: int = 25

func _ready():
	set_as_toplevel(true)

func _process(_delta) -> void:
	current_point = get_parent().global_position

	add_point(current_point)

	while get_point_count() > length:
		remove_point(0)
	pass

func stop() -> void:
	set_process(false)
	var tw := get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0, time_to_dissappear)
	
	yield(tw, "finished")
	
	queue_free()
	
