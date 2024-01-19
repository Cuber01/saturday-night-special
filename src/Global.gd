extends Node2D

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
const GRAVITY_FORCE: int = 5

func calculate_points_in_circle(r: int, point_num: int):
	var points = []
	for i in point_num:
		points.append(Vector2(
							r*cos((i*2*PI)/point_num),
							r*sin((i*2*PI)/point_num)))
	return points

func bool_as_int(b: bool) -> int:
	if b:
		return 1
	else: 
		return -1


