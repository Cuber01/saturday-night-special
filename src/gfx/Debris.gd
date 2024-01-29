extends RigidBody2D

func init(pos: Vector2) -> void:
	global_position = pos

func _on_Debris_body_entered(body: Node) -> void:
	$Sprite.frame = 1
	$Sprite.playing = true

func _on_Sprite_animation_finished() -> void:
	queue_free()
	
func _on_DespawnTimer_timeout() -> void:
	queue_free()
