extends PickupableObject
class_name Crate

var hitpoints: int = 50

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

func take_damage(damage: int) -> bool:
	hitpoints -= damage
	
	if hitpoints < 0:
		queue_free()
		return true
	else:
		return false
