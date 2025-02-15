extends Control

# Game state
var story_data = {}
var current_node_id = "start"
var player_data = {
	"health": 100,
	"inventory": []
}

# Called when the node enters the scene tree
func _ready():
	load_story()
	load_player_data()
	update_ui()

# Load the story from the JSON file
func load_story():
	var file = FileAccess.open("res://assets/story.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json = JSON.new()  # Create a JSON instance
		var error = json.parse(json_text)  # Parse the JSON text
		if error == OK:
			story_data = json.get_data()  # Get the parsed data
		else:
			print("Failed to parse story.json: ", json.get_error_message())
		file.close()
	else:
		print("Failed to load story.json")

# Update the UI based on the current story node
func update_ui():
	var current_node = story_data[current_node_id]
	$StoryText.text = current_node["text"]
	
	# Update choice buttons
	for i in range(3):
		var button = get_node("Choice" + str(i + 1))
		if i < current_node["choices"].size():
			button.text = current_node["choices"][i]["text"]
			button.visible = true
		else:
			button.visible = false

# Handle button presses
func _on_choice1_pressed():
	handle_choice(0)

func _on_choice2_pressed():
	handle_choice(1)

func _on_choice3_pressed():
	handle_choice(2)

# Process player choices
func handle_choice(choice_idx):
	var current_node = story_data[current_node_id]
	var next_node_id = current_node["choices"][choice_idx]["next"]
	current_node_id = next_node_id
	save_player_data()  # Save progress
	update_ui()

# Save player data to a file
func save_player_data():
	var file = FileAccess.open("user://player_data.json", FileAccess.WRITE)
	if file:
		var data = {
			"current_node_id": current_node_id,
			"health": player_data["health"],
			"inventory": player_data["inventory"]
		}
		var json = JSON.new()  # Create a JSON instance
		var json_text = json.stringify(data)  # Convert data to JSON string
		file.store_string(json_text)
		file.close()
	else:
		print("Failed to save player data")

# Load player data from a file
func load_player_data():
	var file = FileAccess.open("user://player_data.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json = JSON.new()  # Create a JSON instance
		var error = json.parse(json_text)  # Parse the JSON text
		if error == OK:
			var data = json.get_data()  # Get the parsed data
			current_node_id = data["current_node_id"]
			player_data["health"] = data["health"]
			player_data["inventory"] = data["inventory"]
		else:
			print("Failed to parse player_data.json: ", json.get_error_message())
		file.close()
	else:
		print("No saved data found. Starting fresh.")
