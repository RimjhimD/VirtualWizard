extends Control

# Declare the variables and bind them to the scene nodes
@onready var music_slider = $MainContainer/MusicContainer/MusicSlider
@onready var sfx_slider = $MainContainer/SFXContainer/SFXSlider
@onready var back_button = $BackButton
@onready var footer_label = $FooterLabel

# Path for the user settings file
var settings_file_path = "user_settings.json"

# Default user settings
var default_settings = {
	"music_volume": 1.0,
	"sfx_volume": 1.0
}

# Called when the node enters the scene tree
func _ready():
	footer_label.text = "Developed by Shinzuu, Rii, SKB, Noha"
	
	# Debug: Print slider paths
	print("Music Slider Path: ", music_slider)
	print("SFX Slider Path: ", sfx_slider)
	
	# Check if the sliders are valid before proceeding
	if music_slider and sfx_slider:
		# Load settings from the local file
		load_settings()
		
		# Connect UI signals
		music_slider.value_changed.connect(_on_music_slider_changed)
		sfx_slider.value_changed.connect(_on_sfx_slider_changed)
		back_button.pressed.connect(_on_back_button_pressed)
	else:
		print("Error: Sliders are not properly assigned in the scene!")

# Function to save settings locally
func save_settings():
	# Save the music and SFX settings locally
	var settings_data = {
		"music_volume": music_slider.value,
		"sfx_volume": sfx_slider.value
	}
	
	# Save the settings to a JSON file
	var file = FileAccess.open(settings_file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings_data))
		file.close()
		print("Settings saved locally:", settings_data)
	else:
		print("Error: Could not save settings to file.")

# Function to load settings from local storage
func load_settings():
	if FileAccess.file_exists(settings_file_path):
		var file = FileAccess.open(settings_file_path, FileAccess.READ)
		var settings_data = file.get_as_text()
		file.close()
		
		# Parse the JSON data
		var json = JSON.new()
		var parse_error = json.parse(settings_data)
		
		if parse_error == OK:
			var loaded_settings = json.get_data()
			# Apply loaded settings to the sliders if valid
			if music_slider:
				music_slider.value = loaded_settings.get("music_volume", default_settings["music_volume"])
			if sfx_slider:
				sfx_slider.value = loaded_settings.get("sfx_volume", default_settings["sfx_volume"])
			print("Settings loaded:", loaded_settings)
		else:
			print("Error parsing settings JSON: ", json.get_error_message())
			# Apply default settings if parsing fails
			if music_slider:
				music_slider.value = default_settings["music_volume"]
			if sfx_slider:
				sfx_slider.value = default_settings["sfx_volume"]
	else:
		print("Settings file not found, using default settings.")
		# Apply default settings if the file doesn't exist
		if music_slider:
			music_slider.value = default_settings["music_volume"]
		if sfx_slider:
			sfx_slider.value = default_settings["sfx_volume"]

# Functions to handle slider changes
func _on_music_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	save_settings()

func _on_sfx_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	save_settings()

# Function to go back to the main menu
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
