extends Sprite
class_name paint

var surface_image: Image = Image.new()
var surface_texture: ImageTexture = ImageTexture.new()
var blood_texture: ImageTexture = ImageTexture.new()
var blood_image: Image = Image.new()

var dynamic_blood: Resource = preload("res://scenes/gfx/DynamicBlood.tscn")

func _ready() -> void:
	#create our surface image and display it
	surface_image.create(1500, 1000, false, Image.FORMAT_RGBAH)
	surface_image.fill(Color(0,0,0,0))
	surface_texture.create_from_image(surface_image, 4)
	
	#We do this once, instead of every single time in blood objects
	blood_image.load("res://assets/img/gfx/blood.png")
	blood_image.convert(Image.FORMAT_RGBAH)
	blood_texture.create_from_image(blood_image, 4)
	
	texture = surface_texture
	
func draw_blood(draw_pos: Vector2) -> void:
	surface_image.lock() 
	surface_image.blit_rect(blood_image,
							Rect2(Vector2(0,0), Vector2(3,3)),
							draw_pos)
	surface_image.unlock() 

func remove_blood(rect: Rect2) -> void:
	pass
	
func clear_surface() -> void:
	surface_image.fill(Color(0,0,0,0))
	
func _physics_process(delta: float) -> void:
	surface_texture.create_from_image(surface_image)
