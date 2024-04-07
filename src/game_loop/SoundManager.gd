extends Node2D

var sfx_players: Array
var sfx_players_amount: int
var sounds: Array = [
					preload("res://assets/audio/sfx/explosion1.wav"), # 0
					preload("res://assets/audio/sfx/explosion2.wav"), # 1
					preload("res://assets/audio/sfx/jump.wav"),		  # 2
					preload("res://assets/audio/sfx/shoot1.wav"),	  # 3
					preload("res://assets/audio/sfx/shoot2.wav"),	  # 4
					preload("res://assets/audio/sfx/shoot3.wav"),	  # 5
					preload("res://assets/audio/sfx/ui_focus.wav"),	  # 6
					preload("res://assets/audio/sfx/victory.wav"),    # 7
					preload("res://assets/audio/sfx/reload1.wav"),	  # 8
					preload("res://assets/audio/sfx/reload2.wav"),	  # 9
					preload("res://assets/audio/sfx/shoot1.wav"),	  # 10
					preload("res://assets/audio/sfx/shoot2.wav"),	  # 11
					preload("res://assets/audio/sfx/shoot3.wav"),	  # 12
					preload("res://assets/audio/sfx/shoot4.wav"),	  # 13
					preload("res://assets/audio/sfx/shoot_shotgun.wav"), # 14
					preload("res://assets/audio/sfx/snowball_hit1.wav"), # 15
					preload("res://assets/audio/sfx/snowball_hit2.wav"), # 16
					preload("res://assets/audio/sfx/icegun_shoot1.wav"), # 17
					preload("res://assets/audio/sfx/icegun_shoot2.wav"), # 18
					preload("res://assets/audio/sfx/icegun_shoot3.wav"), # 19
					preload("res://assets/audio/sfx/freeze.wav"),        # 20 
					preload("res://assets/audio/sfx/no_ammo.wav"),       # 21
					preload("res://assets/audio/sfx/unfreeze.wav"),      # 22 
					preload("res://assets/audio/sfx/activate_mine.wav"), # 23
					preload("res://assets/audio/sfx/squish_death.wav"),  # 24
					preload("res://assets/audio/sfx/door-open.wav"),     # 25
					preload("res://assets/audio/sfx/door-blocked.wav")   # 26
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
	var new_track: int = Global.rng.randi_range(0, music_tracks.size() - 1)
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

func change_music_volume(volume: int) -> void:
	music_player.volume_db = volume	
	
func change_sfx_volume(volume: int) -> void:
	for player in sfx_players:
		player.volume_db = volume
