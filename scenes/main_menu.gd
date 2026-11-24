extends Control

@onready var som_botao = $SomBotao

# Grab the Play button
@onready var btn_jogar = $Botoes/TextureButton 

# Grab Options buttons
@onready var btn_musica = $Opcoes/Musica
@onready var icon_on = $Opcoes/Musica/On
@onready var icon_off = $Opcoes/Musica/Off
@onready var btn_sair = $Opcoes/Sair

# Grab your background music node
@onready var musica_menu = $MusicaMenu

# --- AGE & SCHOOL POP-UP VARIABLES ---
@onready var age_popup = $AgePopup
@onready var name_input = $AgePopup/TexturaPopUp/NameEdit
@onready var age_input = $AgePopup/TexturaPopUp/Idade # Agora é LineEdit!
@onready var school_dropdown = $AgePopup/TexturaPopUp/SchoolDropdown
@onready var confirm_button = $AgePopup/TexturaPopUp/TextureButton
@onready var school_request = $SchoolRequest # Nó HTTPRequest na raiz do MainMenu

const FIREBASE_SCHOOLS_URL = "https://math-fag-default-rtdb.firebaseio.com/schools.json"

func _ready():
	icon_on.show()
	icon_off.hide()
	
	# 1. Iniciar busca das escolas no Firebase
	if school_request:
		school_request.request_completed.connect(_on_schools_request_completed)
		fetch_schools_from_firebase()
	
	# --- CHECK IF USER REGISTERED BEFORE ---
	Global.load_game()
	if Global.player_age > 0 and Global.player_school != "":
		# Já cadastrado! Pula o pop-up.
		age_popup.hide() 
		btn_jogar.grab_focus()
	else:
		# Primeiro acesso: exibe o pop-up de cadastro.
		age_popup.show()
		confirm_button.pressed.connect(_on_confirm_button_pressed)
		
		# Limpa e configura o LineEdit de Idade (opcionalmente coloca um placeholder)
		age_input.text = ""
		
		# Dropdown de Escola (placeholder inicial)
		school_dropdown.add_item("Selecione a Escola")
		school_dropdown.set_item_disabled(0, true)
		school_dropdown.select(0)
		school_dropdown.text = "Selecione a Escola"
			
		name_input.grab_focus()
		
	# --- CONTROLLER SUPPORT (Visuals) ---
	btn_jogar.focus_entered.connect(_on_texture_button_mouse_entered)
	btn_jogar.focus_exited.connect(_on_texture_button_mouse_exited)
	
	btn_musica.focus_entered.connect(_on_musica_mouse_entered)
	btn_musica.focus_exited.connect(_on_musica_mouse_exited)
	
	btn_sair.focus_entered.connect(_on_sair_mouse_entered)
	btn_sair.focus_exited.connect(_on_sair_mouse_exited)

# --- FIREBASE SCHOOL FETCH LOGIC ---
func fetch_schools_from_firebase() -> void:
	var error = school_request.request(FIREBASE_SCHOOLS_URL)
	if error != OK:
		print("Erro ao solicitar lista de escolas do Firebase.")

func _on_schools_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var schools_data = json.get_data()
			if typeof(schools_data) == TYPE_DICTIONARY:
				school_dropdown.clear()
				school_dropdown.add_item("Selecione a Escola")
				school_dropdown.set_item_disabled(0, true)
				
				# Preenche com as escolas vindas do Firebase (ex: Antônio Rockenbach, Paulo Freire)
				for school_id in schools_data.keys():
					var school_info = schools_data[school_id]
					if school_info is Dictionary and school_info.has("name"):
						school_dropdown.add_item(school_info["name"])
				
				school_dropdown.select(0)
		else:
			print("Falha ao analisar o JSON de escolas.")
	else:
		print("Erro HTTP ao buscar escolas. Código: ", response_code)

# --- POP-UP LOGIC ---

func _on_confirm_button_pressed():
	var entered_name = name_input.text.strip_edges()
	var entered_age_text = age_input.text.strip_edges()
	
	# Valida se preencheu o nome, se a idade é um número válido e se selecionou a escola
	if entered_name != "" and entered_age_text.is_valid_int() and school_dropdown.selected > 0:
		var selected_school_text = school_dropdown.get_item_text(school_dropdown.selected)
		
		# 1. Salva as informações globalmente
		Global.player_name = entered_name
		Global.player_age = int(entered_age_text)
		Global.player_school = selected_school_text
		
		# 2. Salva localmente e sincroniza com o Firebase
		Global.save_game() 
		Global.sync_to_cloud() 
		
		# 3. Fecha o pop-up e foca no botão de jogar
		age_popup.hide()
		btn_jogar.grab_focus()
	else:
		print("Preencha o nome, digite uma idade válida e escolha uma escola!")

# --- PLAY BUTTON ---

func _on_texture_button_pressed():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	btn_jogar.disabled = true
	som_botao.play()
	musica_menu.stop()
	await som_botao.finished
	Global.start_playlist()
	SceneManager.change_scene("res://scenes/level_select.tscn", {
	"pattern": "squares",
	"speed": 2.5,
	"wait_time": 0.15
})

func _on_texture_button_mouse_entered():
	btn_jogar.modulate = Color(0.758, 0.758, 0.758, 1.0)

func _on_texture_button_mouse_exited():
	btn_jogar.modulate = Color(1.0, 1.0, 1.0)

# --- MUSIC BUTTON ---

func _on_musica_pressed():
	som_botao.play()
	
	if musica_menu.playing:
		musica_menu.stream_paused = true
		icon_on.hide()
		icon_off.show()
	else:
		musica_menu.stream_paused = false
		icon_on.show()
		icon_off.hide()

func _on_musica_mouse_entered():
	btn_musica.modulate = Color(0.758, 0.758, 0.758, 1.0)

func _on_musica_mouse_exited():
	btn_musica.modulate = Color(1.0, 1.0, 1.0)

# --- EXIT BUTTON ---

func _on_sair_pressed() -> void:
	btn_sair.disabled = true
	som_botao.play()
	await som_botao.finished
	get_tree().quit()

func _on_sair_mouse_entered() -> void:
	btn_sair.modulate = Color(0.758, 0.758, 0.758, 1.0)

func _on_sair_mouse_exited() -> void:
	btn_sair.modulate = Color(1.0, 1.0, 1.0)
