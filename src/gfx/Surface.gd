extends Sprite

var surface_image: Image = Image.new()

var dynamic_blood: Resource = preload("res://scenes/gfx/DynamicBlood.tscn")

const SURFACE_IMG_WIDTH = 1500
const SURFACE_IMG_HEIGHT = 1000

func _ready() -> void:
	texture = ImageTexture.new()
	surface_image.create(SURFACE_IMG_WIDTH, SURFACE_IMG_HEIGHT, false, Image.FORMAT_RGBAH)
	surface_image.fill(Color(0,0,0,0))
	texture.create_from_image(surface_image)
	
func draw_blood(draw_pos: Vector2) -> void:
	surface_image.lock()
	surface_image.set_pixel(draw_pos.x, draw_pos.y, Color(1,0,0,1))
	surface_image.unlock()

func remove_blood(rect: Rect2) -> void:
	surface_image.lock()
	for i in rect.size.x:
		for j in rect.size.y:
			surface_image.set_pixel(rect.position.x+SURFACE_IMG_WIDTH/2+i,
			 rect.position.y+SURFACE_IMG_HEIGHT/2+j, Color(1,1,1,1))
	surface_image.unlock()
	
func clear_surface() -> void:
	surface_image.fill(Color(0,0,0,0))
	
func _physics_process(delta: float) -> void:
	texture.create_from_image(surface_image)
	
	if (Input.is_action_pressed("mb_left")):
		for i in range(1):
			var blood_instance = dynamic_blood.instance()
			blood_instance.hspeed = rand_range(-3,1)
				
			blood_instance.global_position = get_global_mouse_position()
			add_child(blood_instance) 
	
