extends Node2D

# We spawn stuff here
var world: Object
export(PickupableObject.Type) var type = PickupableObject.Type.PISTOL

var weapon_scn: PackedScene = null
var weapon: PickupableObject = null

onready var SpawnTimer = $SpawnTimer
const SPAWN_DELAY: float = 5.0

func _ready():
	match type:
		PickupableObject.Type.PISTOL:
			weapon_scn = preload("res://scenes/Pistol.tscn")
			
	world = get_parent()
	spawn()

func _process(delta) -> void:
	if weapon == null and SpawnTimer.time_left == 0:
		SpawnTimer.start(SPAWN_DELAY)
	
func spawn() -> void:
	weapon = weapon_scn.instance()
	weapon.init(self.global_position, self)
	world.call_deferred("add_child", weapon)

func _on_SpawnTimer_timeout() -> void:
	spawn()

func _on_weapon_picked_up() -> void:
	weapon = null
