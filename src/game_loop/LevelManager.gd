extends Node2D
class_name LevelManager

var levels: Array
var level_amount: int

var my_match: Object
var current_level: Object

const PATH = "res://scenes/levels/"

func _init(lm_match: Object) -> void:
	my_match = lm_match
	prepare_levels()

func prepare_levels() -> void:
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
	level_amount = levels.size()
	
func load_level(index: int) -> void:
	var new_level = levels[index].instance()
	
	if current_level != null:
		my_match.remove_child(current_level)
	
	current_level = new_level
	my_match.add_child(current_level)
	
