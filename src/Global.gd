extends Node2D

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
const GRAVITY_FORCE: int = 275

func calculate_points_in_circle(r: int, point_num: int):
	var points = []
	for i in point_num:
		points.append(Vector2(
							r*cos((i*2*PI)/point_num),
							r*sin((i*2*PI)/point_num)))
	return points
