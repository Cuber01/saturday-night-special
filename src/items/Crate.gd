extends PickupableObject

var held_hitbox:Vector2 = Vector2(2, 12)
var normal_hitbox = Vector2(12,12)

func _use() -> void:
	pass
	
func _pick_up(player: Object) -> void:
	._pick_up(player)
	$HeldHitbox.disabled = false

func _drop(throw_vel: Vector2) -> void:
	._drop(throw_vel)
	$HeldHitbox.disabled = true

func _flip_additional_parts() -> void:
	$HeldHitbox.position.x = -$HeldHitbox.position.x
