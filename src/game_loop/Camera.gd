extends Camera2D

var noise: OpenSimplexNoise
var noise_y: int = 0

const MOVE_SPEED: float = 0.5  # camera position lerp speed
const ZOOM_SPEED: float = 0.1  # camera zoom lerp speed
const MIN_ZOOM: int = 1  # camera won't zoom closer than this
const MAX_ZOOM: int = 16  # camera won't zoom farther than this
const MARGIN: Vector2 = Vector2(200, 50)  # include some buffer area around targets

const DECAY = 0.9  # How quickly the shaking stops [0, 1].
const MAX_OFFSET = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
const MAX_ROLL = 0.1  # Maximum rotation in radians (use sparingly).

var trauma = 0.0  # Current shake strength from 0-1
var trauma_power = 2  # Trauma exponent. Use [2, 3].

onready var game_size := Vector2(100, 55)
onready var window_scale := (OS.window_size / game_size).x
onready var actual_cam_pos := global_position

var targets = [] 

onready var screen_size = get_viewport_rect().size

func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func _process(_delta):
	if !targets:
		return
	
	move_to_center()
	handle_zoom()
	
	if trauma > 0:
		trauma = max(trauma * DECAY, 0)
		shake()


func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = MAX_ROLL * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = MAX_OFFSET.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = MAX_OFFSET.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)

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
	
	var unrounded_zoom: Vector2 = lerp(zoom, Vector2.ONE * new_zoom, ZOOM_SPEED)
	zoom = unrounded_zoom

func add_target(tar: Object) -> void:
	if not tar in targets:
		targets.append(tar)

func remove_target(tar: Object) -> void:
	if tar in targets:
		targets.erase(tar)

func clear_targets() -> void:
	targets.clear()
