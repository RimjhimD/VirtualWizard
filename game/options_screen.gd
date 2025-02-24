extends Control

# Declare the variables and bind them to the scene nodes
@onready var music_slider = $MusicSlider
@onready var sfx_slider = $SFXSlider
@onready var back_button = $BackButton
@onready var footer_label = $FooterLabel
@onready var firebase = $Firebase

# Declare user data (gold, health, mana, stage)
var user_data = {
	"gold": 100,
	"health": 100,
	"mana": 100,
	"stage": 0
}

# Called when the node enters the scene tree
func _ready():
	footer_label.text = "Developed by Shinzuu, Rii, SKB, Noha"
	
	# Load settings from Firebase (this will also load user data)
	load_settings()
	
	# Connect UI signals
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	back_button.pressed.connect(_on_back_pressed)

# Function to save settings and user data to Firebase
func save_settings():
	# Save the music and SFX settings
	var settings_data = {
		"music_volume": music_slider.value,
		"sfx_volume": sfx_slider.value
	}
	firebase.save_data("user_settings", settings_data)
	
	# Save the user data (gold, health, mana, stage)
	firebase.save_data("user_data", user_data)
	print("Settings and user data saved successfully!")

# Function to load settings and user data from Firebase
func load_settings():
	# Load user settings (music and SFX volumes)
	var settings_data = firebase.load_data("user_settings")
	if settings_data:
		music_slider.value = settings_data.get("music_volume", 1.0)
		sfx_slider.value = settings_data.get("sfx_volume", 1.0)
	
	# Load user data (gold, health, mana, stage)
	var user_data_from_firebase = firebase.load_data("user_data")
	if user_data_from_firebase:
		user_data = user_data_from_firebase
		print("User data loaded from Firebase: ", user_data)
	else:
		print("No user data found, loading defaults.")
		# If no user data is found, set default values and save them
		save_settings()

# Functions to handle slider changes
func _on_music_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	save_settings()

func _on_sfx_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	save_settings()

# Function to go back to the main menu
func _on_back_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
