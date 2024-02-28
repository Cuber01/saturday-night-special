extends StaticBody2D

var hitpoints: int = 10

func take_damage(damage: int, damage_type: int = Global.DamageType.HURT) -> bool:
	hitpoints -= damage
	
	if hitpoints < 0:
		queue_free()
		return true
	else:
		return false

func _on_PlayerDetector_body_entered(body: Node) -> void:
	if body is Player or body is Crate:
		body.take_damage(Global.DAMAGE_KILL)
