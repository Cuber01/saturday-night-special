extends KinematicBody2D

enum State {
	OPEN_TO_RIGHT,
	OPEN_TO_LEFT,
	CLOSED
}

const CLOSE_TIME: int = 2
var state = State.CLOSED

var hitpoints: int = 50

func open(to_right: bool) -> void:
	$Hitbox.set_deferred("disabled", true)
	if to_right:
		$AnimatedSprite.frame = 1
		state = State.OPEN_TO_RIGHT
	else:
		$AnimatedSprite.frame = 2
		state = State.OPEN_TO_LEFT
	$CloseTimer.start(CLOSE_TIME)

func close() -> void:
	$Hitbox.set_deferred("disabled", false)
	$AnimatedSprite.frame = 0
	state = State.CLOSED

func attempt_open(to_right: bool) -> void:
	if state != State.CLOSED:
		return
	
	var blocked_by: Array
	
	if to_right:
		blocked_by = $DetectLeft.get_overlapping_bodies()
	else:
		blocked_by = $DetectRight.get_overlapping_bodies()
	
	if blocked_by:
		pass
		# Door locked sound
	else: 
		open(to_right)

func _on_DetectRight_body_entered(body: Node) -> void:
	if body is Player and not body.is_frozen:
		attempt_open(true)

func _on_DetectLeft_body_entered(body: Node) -> void:
	if body is Player and not body.is_frozen:
		attempt_open(false)

func _on_CloseTimer_timeout() -> void:
	# If something blocks door closing, we repeat the timer
	if $DetectInDoor.get_overlapping_bodies():
		$CloseTimer.start(CLOSE_TIME)
	elif state == State.OPEN_TO_RIGHT:
		if not $DetectLeft.get_overlapping_bodies():
			close()
		else:
			$CloseTimer.start(CLOSE_TIME)
	elif state == State.OPEN_TO_LEFT:
		if not $DetectRight.get_overlapping_bodies():
			close()
		else: 
			$CloseTimer.start(CLOSE_TIME)
			
func take_damage(damage: int,
				 damage_type: int = Global.DamageType.HURT,
				 direction: Vector2 = Vector2(0,-1)) -> bool:
	hitpoints -= damage
	
	if hitpoints < 0:
		queue_free()
		return true
	else:
		return false
