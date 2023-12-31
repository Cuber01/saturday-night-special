extends Node2D

onready var timer: Timer = $NextRoundTimer
const TIME_TIL_NEXT_ROUND: float = 3.0

var level_manager: LevelManager

var round_count = 0

var player_amount: int = 2
var players_alive: int = 2

var scoreboard: Array = [0, 0, 0, 0]
var alive_board: Array = [null, null, null, null]


func _ready() -> void:
	reset_board(scoreboard, 0)
	reset_board(alive_board, true)
	
	Util.rng.randomize()
	
	level_manager = LevelManager.new(self)
	#level_manager.load_level(rng.randi_range(0, level_manager.level_amount - 1))
	level_manager.load_level(0)
	
	SoundManager.init(10)
	SoundManager.play_music()


func reset_board(board: Array, value) -> void:
	for i in (player_amount - 1):
		board[i] = value

func print_scoreboard() -> void:
	print("ROUND " + str(round_count))
	print("p0: " + str(scoreboard[0]))
	print("p1: " + str(scoreboard[1]))

func _on_player_died(player_index: int) -> void:
	players_alive -= 1
	alive_board[player_index] = false
	
	if players_alive <= 1:
		timer.start(TIME_TIL_NEXT_ROUND)

func _on_NextRoundTimer_timeout():
	# Count a point for everyone who's alive
	for i in (player_amount - 1):
		if alive_board[i] == true:
			scoreboard[i] += 1
	
	round_count += 1
	print_scoreboard()
	
	players_alive = player_amount
	reset_board(alive_board, true)
	level_manager.load_level(Util.rng.randi_range(0, level_manager.level_amount - 1))
