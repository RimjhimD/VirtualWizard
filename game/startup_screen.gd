extends Control

@export var background_image: Texture
@export var image_paths: Array[String]  # List of image paths to preload (if necessary)

# Paths for the user settings and user data files
var settings_file_path = "user_settings.json"
var user_data_file_path = "user_data.json"

# Default user settings
var default_settings = {
	"music_volume": 1.0,
	"sfx_volume": 1.0
}

# Default user data structure
var default_user_data = {
	"user_id": "guest",
	"gold": 100,
	"health": 100,
	"mana": 50,
	"progress": 0
}

var user_settings = {}
var user_data = {}

@onready var loading_label = $LoadingLabel

func _ready():
	# Load user settings and user data
	load_user_settings()
	load_user_data()
	# Proceed to loading screen
	load_loading_screen()

# Function to load user settings
func load_user_settings():
	if FileAccess.file_exists(settings_file_path):
		var file = FileAccess.open(settings_file_path, FileAccess.READ)
		var settings_data = file.get_as_text()
		
		# Create JSON parser instance
		var json = JSON.new()
		var parse_error = json.parse(settings_data)
		
		if parse_error == OK:
			user_settings = json.get_data()
			print("User settings loaded successfully!")
		else:
			print("Error parsing settings JSON: ", json.get_error_message())
			user_settings = default_settings
		file.close()
	else:
		print("Settings file not found, using default settings.")
		user_settings = default_settings

# Function to load user data (such as stats and progress)
func load_user_data():
	if FileAccess.file_exists(user_data_file_path):
		var file = FileAccess.open(user_data_file_path, FileAccess.READ)
		var data = file.get_as_text()
		
		# Create JSON parser instance
		var json = JSON.new()
		var parse_error = json.parse(data)
		
		if parse_error == OK:
			user_data = json.get_data()
			print("User data loaded successfully!")
		else:
			print("Error parsing user data JSON: ", json.get_error_message())
			user_data = default_user_data
		file.close()
	else:
		print("User data file not found, creating new user data.")
		user_data = default_user_data

# Function to load loading screen
func load_loading_screen():
	# Call your loading screen here (or transition to it)
	get_tree().change_scene_to_file("res://LoadingScreen.tscn")
