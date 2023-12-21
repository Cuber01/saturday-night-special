extends AnimatedSprite

var anim_name: String

func init(pos: Vector2, animation_name: String):
	position = pos
	anim_name = animation_name

func _ready():
	play(anim_name)
	yield(self, "animation_finished")
	queue_free()
