extends Control

# Node references
@onready var hp_bar: ProgressBar = $MarginContainer/OverallContainer/TopBar/HpBar
@onready var mp_bar: ProgressBar = $MarginContainer/OverallContainer/TopBar/MpBar
@onready var exp_bar: ProgressBar = $MarginContainer/OverallContainer/TopBar/ExpBar
@onready var story_text: RichTextLabel = $MarginContainer/OverallContainer/ScrollContainer/RichTextLabel
@onready var choice_container: VBoxContainer = $MarginContainer/OverallContainer/ChoiceContainer
@onready var back_to_menu_button: Button = $MarginContainer/OverallContainer/HBoxContainer/BackToMenu
@onready var fight_button: Button = $MarginContainer/OverallContainer/HBoxContainer/Fight
@onready var inventory_button: Button = $MarginContainer/OverallContainer/HBoxContainer/Inventory

# User data file
const USER_DATA_FILE = "user://user_json.json"
const STORY_FILE = "res://story.json"
var user_data = {}
var story_data = {}

# Story state
var current_progress: String = "start"

func _ready():
	load_user_data()
	load_story_data()
	update_bars()
	display_story()
	connect_buttons()

# Load user data from file
func load_user_data():
	if FileAccess.file_exists(USER_DATA_FILE):
		var file = FileAccess.open(USER_DATA_FILE, FileAccess.READ)
		user_data = JSON.parse_string(file.get_as_text())
	else:
		user_data = {"user_id": "guest", "gold": 100, "health": 100, "mana": 50, "progress": "start"}
	current_progress = user_data["progress"]

# Save user data to file
func save_user_data():
	var file = FileAccess.open(USER_DATA_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(user_data))

# Load story from JSON
func load_story_data():
	if FileAccess.file_exists(STORY_FILE):
		var file = FileAccess.open(STORY_FILE, FileAccess.READ)
		story_data = JSON.parse_string(file.get_as_text())

# Update UI bars
func update_bars():
	hp_bar.value = user_data["health"]
	mp_bar.value = user_data["mana"]
	exp_bar.value = 0  # EXP system not implemented yet

# Display the story with animation
func display_story():
	if current_progress in story_data:
		var entry = story_data[current_progress]
		animate_story_text(entry["text"])
		populate_choices(entry["choices"])

# Animate text display
func animate_story_text(text: String):
	story_text.text = ""
	var i = 0
	while i < text.length():
		story_text.text += text[i]
		await get_tree().create_timer(0.05).timeout
		i += 1

# Populate choices dynamically
func populate_choices(choices: Array):
	for child in choice_container.get_children():
		child.queue_free()
	
	for choice in choices:
		var choice_button = Button.new()
		choice_button.text = choice["text"]
		choice_button.disabled = choice.get("disabled", false)
		choice_container.add_child(choice_button)
		choice_button.pressed.connect(_on_choice_selected.bind(choice))

# Handle choice selection
func _on_choice_selected(choice: Dictionary):
	if "fight" in choice:
		start_fight(choice["fight"])
	else:
		update_user_data(choice)
		current_progress = choice["next"]
		user_data["progress"] = current_progress
		save_user_data()
		display_story()

# Update user data based on choice effects
func update_user_data(choice: Dictionary):
	if "health" in choice:
		user_data["health"] += choice["health"]
	if "gold" in choice:
		user_data["gold"] += choice["gold"]
	if "mana" in choice:
		user_data["mana"] += choice["mana"]
	user_data["health"] = max(0, user_data["health"])  # Prevent negative HP
	save_user_data()

# Handle fights
func start_fight(enemy: String):
	print("Starting fight with:", enemy)
	get_tree().change_scene_to_file("res://fight_screen.tscn")
	await get_tree().process_frame  # Wait for fight to finish
	process_fight_result()

# Process fight result
func process_fight_result():
	if user_data["health"] <= 0:
		game_over()
	else:
		current_progress = "after_fight"
		user_data["progress"] = current_progress
		save_user_data()
		display_story()

# Handle game over
func game_over():
	print("Game Over")
	get_tree().change_scene_to_file("res://game_over.tscn")

# Connect buttons
func connect_buttons():
	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	inventory_button.pressed.connect(_on_inventory_pressed)

func _on_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_inventory_pressed():
	update_story_text("You check your inventory.")
# Update story text directly
func update_story_text(text: String):
	story_text.text = text
