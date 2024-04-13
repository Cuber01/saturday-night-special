extends Node2D

onready var timer: Timer = $NextRoundTimer
const TIME_TIL_NEXT_ROUND: float = 3.0

var level_manager: LevelManager

var round_count = 0

var player_amount: int = 2
var players_alive: int = 2

var scoreboard: Array = [0, 0, 0, 0]
var money_board: Array = [0, 0, 0, 0]
var alive_board: Array = [true, true, true, true]

signal sig_round_end

func _ready() -> void:
	reset_board(scoreboard, 0)
	reset_board(money_board, 0)
	reset_board(alive_board, true)
	
	Global.rng.randomize()
	
	level_manager = LevelManager.new(self)
	#level_manager.load_level(rng.randi_range(0, level_manager.level_amount - 1))
	level_manager.load_level(3) # 2
	
	SoundManager.init(10)
	#SoundManager.play_music()

	SoundManager.change_sfx_volume(-5)


func reset_board(board: Array, value) -> void:
	for i in (player_amount - 1):
		board[i] = value

func print_scoreboard() -> void:
	pass # Doesn't work properly
#	print("ROUND " + str(round_count))
#	print("p0: " + str(scoreboard[0]) + " : " + str(money_board[0]))
#	print("p1: " + str(scoreboard[1]) + " : " + str(money_board[1]))

func _on_collected_coin(player_index: int, worth: int) -> void:
	money_board[player_index] += worth

func _on_player_died(player_index: int) -> void:
	players_alive -= 1
	alive_board[player_index] = false
	
	if players_alive <= 1:
		emit_signal("sig_round_end")
		timer.start(TIME_TIL_NEXT_ROUND)

func _on_NextRoundTimer_timeout():
	# Count a point for everyone who's alive
	for i in player_amount:
		if alive_board[i] == true:
			scoreboard[i] += 1
	
	round_count += 1
	print_scoreboard()
	
	players_alive = player_amount
	reset_board(alive_board, true)
	$Surface.clear_surface()
	$Camera.clear_targets()
	level_manager.load_level(Global.rng.randi_range(0, level_manager.level_amount - 1))
