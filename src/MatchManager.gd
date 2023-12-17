extends Node2D

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var level_manager: LevelManager

var player_amount: int = 2
var p1_score: int = 0
var p2_score: int = 0
var p3_score: int = 0
var p4_score: int = 0

func _ready():
	rng.randomize()
	level_manager = LevelManager.new(self)
	level_manager.load_level(rng.randi_range(0, level_manager.level_amount - 1))

func _on_player_died(player_index: int):
	print(str(player_index))
