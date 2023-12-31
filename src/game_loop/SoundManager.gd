extends Node2D

var sfx_players: Array
var sfx_players_amount: int
var sounds: Array = [
						preload("res://assets/audio/sfx/explosion1.wav"),
						preload("res://assets/audio/sfx/explosion2.wav"),
						preload("res://assets/audio/sfx/jump.wav"),
						preload("res://assets/audio/sfx/shoot1.wav"),
						preload("res://assets/audio/sfx/shoot2.wav"),
						preload("res://assets/audio/sfx/shoot3.wav"),
						preload("res://assets/audio/sfx/ui_focus.wav"),
						preload("res://assets/audio/sfx/victory.wav"),
					]

var music_player: AudioStreamPlayer
var current_track: int = -1
var music_tracks: Array = [
							#preload("res://assets/audio/music/Alkakrab/soft_loop.mp3"),
							preload("res://assets/audio/music/Alkakrab/synthwave1.mp3"),
							preload("res://assets/audio/music/Alkakrab/synthwave2.mp3"),
							preload("res://assets/audio/music/Alkakrab/synthwave3.mp3"),
							preload("res://assets/audio/music/Alkakrab/synthwave4.mp3"),
							preload("res://assets/audio/music/Alkakrab/synthwave5.mp3"),
							preload("res://assets/audio/music/Alkakrab/synthwave6.mp3"),
							preload("res://assets/audio/music/Alkakrab/synthwave7.mp3"),
							preload("res://assets/audio/music/Alkakrab/synthwave8.mp3"),
							preload("res://assets/audio/music/Shonoki/16_bit_space.ogg"),
							preload("res://assets/audio/music/Shonoki/future.ogg"),
							preload("res://assets/audio/music/Shonoki/glitch.ogg"),
							preload("res://assets/audio/music/Shonoki/retro_metal.ogg"),
						]

func init(audio_players_amount: int):
	self.sfx_players_amount = audio_players_amount
	
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	for i in sfx_players_amount:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		sfx_players.append(player)
		add_child(player)

func play_music() -> void:
	var new_track: int = Util.rng.randi_range(0, music_tracks.size() - 1)
	if new_track == current_track:
		play_music()
		return 
	
	current_track = new_track
	music_player.stream = music_tracks[current_track]
	music_player.play()
	
	yield(music_player, "finished")
	play_music()
	
func play_sound(index: int) -> void:
	for player in sfx_players:
		if player.playing:
			continue
			
		player.stream = sounds[index]
		player.play() 
		break
