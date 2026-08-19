extends Node

# ==========================================
# PROGRESSION & FIREBASE VARIABLES
# ==========================================
var total_score: int = 0
var levels_unlocked: int = 1
var player_age: int = 0
var player_name: String = "" # <--- NEW: Stores the player's name
var player_uuid: String = ""
var level_errors: Dictionary = {}

var save_path: String = "user://math_fag_save.json"

# Your exact Firebase Database URL
const FIREBASE_URL: String = "https://math-fag-default-rtdb.firebaseio.com/"

# ==========================================
# MUSIC VARIABLES
# ==========================================
var music_player: AudioStreamPlayer
var playlist = [
	preload("res://musicas/1.ogg"),
	preload("res://musicas/2.ogg"),
	preload("res://musicas/3.ogg"),
	preload("res://musicas/4.ogg")
]
var last_song_index: int = -1

# ==========================================
# INITIALIZATION
# ==========================================
func _ready():
	# 1. Load the browser save data (or create a new ID if it's their first time!)
	load_game()
	
	# 2. Create the audio node behind the scenes and attach it
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# 3. When a song naturally finishes, pick a new one
	music_player.finished.connect(play_random_song)

# ==========================================
# SAVE / LOAD / FIREBASE LOGIC
# ==========================================
func save_game():
	var save_dict = {
		"uuid": player_uuid,
		"name": player_name, # <--- NEW: Saves the name locally
		"age": player_age,
		"unlocked": levels_unlocked,
		"score": total_score,
		"errors": level_errors
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_dict))

func load_game():
	# Check if this browser has played the game before
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var saved_data = JSON.parse_string(file.get_as_text())
		if saved_data:
			total_score = saved_data.get("score", 0)
			levels_unlocked = saved_data.get("unlocked", 1)
			player_age = saved_data.get("age", 0)
			player_name = saved_data.get("name", "") # <--- NEW: Loads the name locally
			player_uuid = saved_data.get("uuid", "")
			level_errors = saved_data.get("errors", {}) 
	
	# If there is no UUID found, generate a brand new unique one!
	if player_uuid == "":
		player_uuid = Time.get_datetime_string_from_system() + "_" + str(randi_range(10000, 99999))
		save_game()

func sync_to_cloud():
	# Creates an HTTP request node to talk to Firebase
	var http = HTTPRequest.new()
	add_child(http)
	
	var headers = ["Content-Type: application/json"]
	
	# The data we are sending to your school dashboard
	var data = {
		"name": player_name, # <--- NEW: Sends the name to your dashboard!
		"age": player_age,
		"levels_cleared": levels_unlocked - 1 # If they are ON level 1, they cleared 0!
	}
	
	# Merge the errors directly into the payload!
	for key in level_errors.keys():
		data[key] = level_errors[key]
	
	# Point directly to their unique UUID in the database
	var request_url = FIREBASE_URL + "game_stats/" + player_uuid + ".json"
	
	# Send the data! (METHOD_PATCH updates existing data or creates new data)
	http.request(request_url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(data))
	
	# Wait for Firebase to confirm it received the data, then delete the HTTP node
	await http.request_completed
	http.queue_free()

# ==========================================
# ERROR LOGGING SYSTEM
# ==========================================
func log_error(level_num: int):
	# Create the exact string: "level1_erros"
	var error_key = "level" + str(level_num) + "_erros"
	
	# If this is the first time they made an error on this level, start at 0
	if not level_errors.has(error_key):
		level_errors[error_key] = 0
		
	# Add 1 to the error count
	level_errors[error_key] += 1
	
	# Save locally and push the new number to Firebase instantly!
	save_game()
	sync_to_cloud()

# ==========================================
# MUSIC PLAYLIST LOGIC
# ==========================================
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
