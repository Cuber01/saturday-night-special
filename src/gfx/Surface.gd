extends Sprite
class_name paint

var surface_image: Image = Image.new()
var surface_texture: ImageTexture = ImageTexture.new()
var blood_image: Image = Image.new()

var dynamic_blood: Resource = preload("res://scenes/gfx/DynamicBlood.tscn")

const SURFACE_IMG_WIDTH = 1500
const SURFACE_IMG_HEIGHT = 1000

func _ready() -> void:
	#create our surface image and display it
	surface_image.create(SURFACE_IMG_WIDTH, SURFACE_IMG_HEIGHT, false, Image.FORMAT_RGBAH)
	surface_image.fill(Color(0,0,0,0))
	surface_texture.create_from_image(surface_image, 4)
	
	#We do this once, instead of every single time in blood objects
	blood_image.load("res://assets/img/gfx/blood.png")
	blood_image.convert(Image.FORMAT_RGBAH)
	
	texture = surface_texture
	
var a = true
	
func draw_blood(draw_pos: Vector2) -> void:
	if not a: return
	surface_image.blit_rect(blood_image,
							Rect2(Vector2(0,0), Vector2(1,1)),
							draw_pos)

func remove_blood(rect: Rect2) -> void:
	a = false
	surface_image.fill_rect(Rect2(Vector2(rect.position.x+SURFACE_IMG_WIDTH/2, 
							rect.position.y+SURFACE_IMG_HEIGHT/2), 
							rect.size), 
							Color(1,1,1,0))
	
func clear_surface() -> void:
	surface_image.fill(Color(0,0,0,0))
	
func _physics_process(delta: float) -> void:
	surface_texture.create_from_image(surface_image)
	
	if (Input.is_action_pressed("mb_left")):
		for i in range(1):
			var blood_instance = dynamic_blood.instance()
			blood_instance.hspeed = rand_range(-3,1)
				
			blood_instance.global_position = get_global_mouse_position()
			add_child(blood_instance) 
	
