extends Node

var total_score: int = 0

# The music player that lives forever
var music_player: AudioStreamPlayer

# Put the exact paths to your 4 songs here
var playlist = [
	preload("res://musicas/1.ogg"),
	preload("res://musicas/2.ogg"),
	preload("res://musicas/3.ogg"),
	preload("res://musicas/4.ogg")
]

var last_song_index: int = -1

func _ready():
	# Create the audio node behind the scenes and attach it to the Global backpack
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# When a song naturally finishes, it tells the script to pick a new one
	music_player.finished.connect(play_random_song)

func start_playlist():
	# Only start if it's not already playing (so we don't accidentally restart it)
	if not music_player.playing:
		play_random_song()

func play_random_song():
	# Pick a random number between 0 and 3
	var next_song = randi() % playlist.size()
	
	# If the random number matches the song that just played, roll the dice again!
	while next_song == last_song_index:
		next_song = randi() % playlist.size()
		
	# Save this song as the new "last played"
	last_song_index = next_song
	
	# Load the song and play it
	music_player.stream = playlist[next_song]
	music_player.play()

func stop_playlist():
	music_player.stop()
