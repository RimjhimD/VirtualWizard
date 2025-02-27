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

# Default values
var player_hp: float = 100.0
var player_mp: float = 100.0
var player_exp: float = 0.0
var max_hp: float = 100.0
var max_mp: float = 100.0
var max_exp: float = 100.0

# Story text and choices
var current_story_text: String = "Welcome to the game! What will you do?"
var current_choices: Array = [
	{"text": "Go to the forest", "visible": true, "disabled": false},
	{"text": "Visit the town", "visible": true, "disabled": false},
	{"text": "Check inventory", "visible": true, "disabled": false},
	{"text": "Rest", "visible": true, "disabled": false}
]

func _ready():
	# Initialize UI
	update_bars()
	update_story_text(current_story_text)
	populate_choices(current_choices)
	
	# Connect button signals
	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	fight_button.pressed.connect(_on_fight_pressed)
	inventory_button.pressed.connect(_on_inventory_pressed)
	
	# Connect choice buttons
	for choice_button in choice_container.get_children():
		choice_button.pressed.connect(_on_choice_button_pressed.bind(choice_button.name))

# Update HP, MP, and EXP bars
func update_bars():
	hp_bar.value = (player_hp / max_hp) * 100
	mp_bar.value = (player_mp / max_mp) * 100
	exp_bar.value = (player_exp / max_exp) * 100

# Update story text
func update_story_text(text: String):
	story_text.text = text

# Populate choice buttons
func populate_choices(choices: Array):
	# Clear existing choices
	for child in choice_container.get_children():
		child.queue_free()
	
	# Add new choices
	for choice in choices:
		var choice_button = Button.new()
		choice_button.text = choice["text"]
		choice_button.visible = choice["visible"]
		choice_button.disabled = choice["disabled"]
		choice_button.custom_minimum_size = Vector2(0, 60)
		choice_container.add_child(choice_button)
		choice_button.pressed.connect(_on_choice_button_pressed.bind(choice_button.text))

# Handle choice button presses
func _on_choice_button_pressed(choice_text: String):
	print("Choice selected:", choice_text)
	# Example: Update story text based on choice
	update_story_text("You chose: " + choice_text)
	# Example: Hide the choice buttons after selection
	for choice_button in choice_container.get_children():
		choice_button.visible = false

# Handle back to menu button press
func _on_back_to_menu_pressed():
	print("Back to menu pressed")
	get_tree().change_scene_to_file("res://main_menu.tscn")

# Handle fight button press
func _on_fight_pressed():
	print("Fight button pressed")
	# Example: Update story text for fight
	update_story_text("You prepare for battle!")
	# Example: Update HP/MP after fight
	player_hp -= 10
	player_mp -= 20
	update_bars()

# Handle inventory button press
func _on_inventory_pressed():
	print("Inventory button pressed")
	# Example: Update story text for inventory
	update_story_text("You check your inventory.")
