extends Camera2D

const MOVE_SPEED: float = 0.5  # camera position lerp speed
const ZOOM_SPEED: float = 0.1  # camera zoom lerp speed
const MIN_ZOOM: int = 4  # camera won't zoom closer than this
const MAX_ZOOM: int = 8  # camera won't zoom farther than this
const MARGIN: Vector2 = Vector2(80, 50)  # include some buffer area around targets

var targets = [] 

onready var screen_size = get_viewport_rect().size

func _process(_delta):
	if !targets:
		return
		
	move_to_center()
	handle_zoom()


func move_to_center() -> void:
	var new_pos: Vector2 = Vector2.ZERO
	for target in targets:
		new_pos += target.position
	new_pos = new_pos / targets.size()
	position = lerp(position, new_pos, MOVE_SPEED)

func handle_zoom() -> void:
	var cam_fov: Rect2 = Rect2(position, Vector2.ONE)
	
	# Expand to enclose all targets
	for target in targets:
		cam_fov = cam_fov.expand(target.position)
	
	# Add margin on all sides
	cam_fov = cam_fov.grow_individual(MARGIN.x, MARGIN.y, MARGIN.x, MARGIN.y)
	
	# Make sure we aren't exceeding MIN and MAX ZOOM
	var new_zoom: float
	if cam_fov.size.x > cam_fov.size.y * screen_size.aspect():
		new_zoom = clamp(cam_fov.size.x / screen_size.x, MIN_ZOOM, MAX_ZOOM)
	else:
		new_zoom = clamp(cam_fov.size.y / screen_size.y, MIN_ZOOM, MAX_ZOOM)
	
	zoom = lerp(zoom, Vector2.ONE * new_zoom, ZOOM_SPEED)

func add_target(tar: Object) -> void:
	if not tar in targets:
		targets.append(tar)

func remove_target(tar: Object) -> void:
	if tar in targets:
		targets.erase(tar)
