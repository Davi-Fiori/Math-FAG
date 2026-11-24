extends Node

# ==========================================
# PROGRESSION & FIREBASE VARIABLES
# ==========================================
var total_score: int = 0
var levels_unlocked: int = 1
var player_age: int = 0
var player_name: String = "" 
var player_school: String = "" # <--- NOVO: Armazena a escola do aluno
var player_uuid: String = ""
var level_errors: Dictionary = {}
var selected_char_index: int = 0
var selected_char_scene: String = "res://scenes/caranguejo.tscn"

var save_path: String = "user://math_fag_save.json"

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
	load_game()
	
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.finished.connect(play_random_song)

# ==========================================
# SAVE / LOAD / FIREBASE LOGIC
# ==========================================
func save_game():
	var save_dict = {
		"uuid": player_uuid,
		"name": player_name,
		"age": player_age,
		"school": player_school, # <--- NOVO: Salva a escola localmente
		"unlocked": levels_unlocked,
		"score": total_score,
		"errors": level_errors
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_dict))

func load_game():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var saved_data = JSON.parse_string(file.get_as_text())
		if saved_data:
			total_score = saved_data.get("score", 0)
			levels_unlocked = saved_data.get("unlocked", 1)
			player_age = saved_data.get("age", 0)
			player_name = saved_data.get("name", "")
			player_school = saved_data.get("school", "") # <--- NOVO: Carrega a escola localmente
			player_uuid = saved_data.get("uuid", "")
			level_errors = saved_data.get("errors", {}) 
	
	if player_uuid == "":
		player_uuid = Time.get_datetime_string_from_system() + "_" + str(randi_range(10000, 99999))
		save_game()

func sync_to_cloud():
	var http = HTTPRequest.new()
	add_child(http)
	
	var headers = ["Content-Type: application/json"]
	
	var data = {
		"name": player_name,
		"age": player_age,
		"school": player_school, # <--- NOVO: Envia a escola para o seu painel do Firebase!
		"levels_cleared": levels_unlocked - 1 
	}
	
	for key in level_errors.keys():
		data[key] = level_errors[key]
	
	var request_url = FIREBASE_URL + "game_stats/" + player_uuid + ".json"
	
	http.request(request_url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(data))
	
	await http.request_completed
	http.queue_free()

# ==========================================
# ERROR LOGGING SYSTEM
# ==========================================
func log_error(level_num: int, error_type: String):
	var error_key = "level" + str(level_num) + "_" + error_type
	
	if not level_errors.has(error_key):
		level_errors[error_key] = 0
		
	level_errors[error_key] += 1
	
	save_game()
	sync_to_cloud()

# ==========================================
# MUSIC PLAYLIST LOGIC
# ==========================================
func start_playlist():
	if not music_player.playing:
		play_random_song()

func play_random_song():
	var next_song = randi() % playlist.size()
	while next_song == last_song_index:
		next_song = randi() % playlist.size()
		
	last_song_index = next_song
	music_player.stream = playlist[next_song]
	music_player.play()

func stop_playlist():
	music_player.stop()
