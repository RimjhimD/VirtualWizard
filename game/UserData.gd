extends Node

# Define user data (stats, stage, story progress, etc.)
var user_data = {
	"gold": 100,
	"health": 100,
	"mana": 100,
	"stage": 0,
	"story_progress": {}
}

# Path to save the data
var save_file_path = "user_data.save"

# Called when the node enters the scene tree
func _ready():
	# Try to load existing data if available
	load_user_data()

# Save user data to a file
func save_user_data():
	var file = File.new()
	if file.open(save_file_path, File.WRITE) == OK:
		# Save the data as JSON
		file.store_string(to_json(user_data))
		file.close()
		print("User data saved successfully!")
	else:
		print("Failed to save user data.")

# Load user data from the file
func load_user_data():
	var file = File.new()
	if file.open(save_file_path, File.READ) == OK:
		# Read the data and parse it
		var data = file.get_as_text()
		user_data = parse_json(data)
		file.close()
		print("User data loaded successfully!")
		# Ensure the data is not empty, set defaults if necessary
		if user_data.empty():
			user_data = {
				"gold": 100,
				"health": 100,
				"mana": 100,
				"stage": 0,
				"story_progress": {}
			}
		else:
			# Update your game state with the loaded data
			update_game_state()
	else:
		print("No saved data found, loading defaults.")
		# If no data exists, set default values and save them
		save_user_data()

# Function to update game state with the loaded data
func update_game_state():
	# Update the player stats, stage, and story progress
	print("Loaded Data:", user_data)
	# You can update the player’s health, mana, and gold in the game based on user_data.
	# Example:
	# health = user_data["health"]
	# mana = user_data["mana"]
	# gold = user_data["gold"]
	# stage = user_data["stage"]
