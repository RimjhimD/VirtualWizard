extends Control

# Function to start the game
func _on_start_button_pressed() -> void:
	print("Start pressed")
	# Transition to the game scene (Replace with your game's starting scene)
	get_tree().change_scene_to_file("res://MainGameScreen.tscn")

# Function to go to the options screen
func _on_options_pressed() -> void:
	print("Options pressed")
	# Change to the options screen
	get_tree().change_scene_to_file("res://options_screen.tscn")

# Function to exit the game
func _on_exit_pressed() -> void:
	print("Exit pressed")
	get_tree().quit()
