extends RigidBody2D

export var time_to_dissappear: float
export var min_troque: float
export var max_torque: float
export var min_vel_y: float
export var max_vel_y: float
export var min_vel_x: float
export var max_vel_x: float
export var max_bounce: float

func init(pos: Vector2, var right: bool) -> void:
	self.position = pos
	add_torque(90)
	var vel_x = Global.rng.randf_range(0, max_vel_x)
	set_linear_velocity(Vector2(
		-vel_x if right else vel_x,
		Global.rng.randf_range(min_vel_y, max_vel_y)
	))
	set_bounce(Global.rng.randf_range(0, max_bounce))

func _on_DespawnTimer_timeout() -> void:
	var tw := get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0, time_to_dissappear)
	
	yield(tw, "finished")
	
	queue_free()
