extends Node2D

var levels: Array
var current_level

var rng = RandomNumberGenerator.new()
const PATH = "res://scenes/levels/"

var load_next_level: bool = true

func _ready() -> void:
	load_levels()

func load_levels() -> void:
	var dir = Directory.new()
	dir.open(PATH)
	dir.list_dir_begin()
	
	while true:
		var filename = dir.get_next()
		if filename == "": 
			break # break the loop if there are no more files left
		elif !filename.begins_with("."): # skip "." and ".." directories
			levels.append(load(PATH + filename))
			
	dir.list_dir_end()

func _process(delta) -> void:
	if load_next_level:
		load_level(rng.randi_range(0, levels.size()-1))
		load_next_level = false
		
	if Input.is_action_just_pressed("debug_button"):
		load_next_level = true

	
func load_level(index: int) -> void:
	var new_level = levels[index].instance()
	
	if current_level != null:
		remove_child(current_level)
	
	current_level = new_level
	add_child(new_level)
	
