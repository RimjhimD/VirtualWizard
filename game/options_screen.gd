extends Control

# Declare the variables and bind them to the scene nodes
@onready var music_slider = $MusicSlider
@onready var sfx_slider = $SFXSlider
@onready var back_button = $BackButton
@onready var footer_label = $FooterLabel
@onready var firebase = $Firebase

# Called when the node enters the scene tree
func _ready():
	footer_label.text = "Developed by Shinzuu, Rii, SKB, Noha"
	
	# Load settings from Firebase
	load_settings()
	
	# Connect UI signals
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	back_button.pressed.connect(_on_back_pressed)

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

# Function to save settings to Firebase
func save_settings():
	var data = {
		"music_volume": music_slider.value,
		"sfx_volume": sfx_slider.value
	}
	firebase.save_data("user_settings", data)

# Function to load settings from Firebase
func load_settings():
	var data = firebase.load_data("user_settings")
	if data:
		music_slider.value = data.get("music_volume", 1.0)
		sfx_slider.value = data.get("sfx_volume", 1.0)
