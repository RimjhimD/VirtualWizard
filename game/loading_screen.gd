extends Control

@export var background_image: Texture
@export var fact_interval: float = 5.0  # Interval in seconds
@export var image_paths: Array[String]  # List of image paths to preload

var loading_text = "Loading"
var dot_count = 0
var loading_complete = false
var preloaded_images = {}  # Dictionary to store preloaded images

@onready var bg_panel = $Background
@onready var animation_timer = $AnimationTimer
@onready var fact_timer = $FactTimer
@onready var loading_label = $LoadingLabel
@onready var tween = create_tween()

func _ready():
	# Set background image for Panel
	var stylebox = StyleBoxTexture.new()
	stylebox.texture = background_image
	bg_panel.set("res://loading_screen_background.png", stylebox)

	# Connect signals for timers
	animation_timer.timeout.connect(_on_animation_timer_timeout)
	fact_timer.timeout.connect(_on_fact_timer_timeout)

	# Start loading animation
	animation_timer.start()

	# Start image caching
	preload_images()

	# Fetch and display the first fact
	fetch_random_fact()

	# Start the fact update timer
	fact_timer.start(fact_interval)

# Animate loading dots
func _on_animation_timer_timeout():
	if not loading_complete:
		dot_count = (dot_count + 1) % 4
		loading_label.text = loading_text + ".".repeat(dot_count)

# Fetch and display a random fact
func _on_fact_timer_timeout():
	fetch_random_fact()

# Function to fetch a random fact from an API
func fetch_random_fact():
	var request = HTTPRequest.new()
	add_child(request)  # Add request node to the scene
	request.request_completed.connect(_on_request_completed.bind(request))  # Bind request for cleanup
	var error = request.request("http://numbersapi.com/random/trivia")
	if error != OK:
		$FactLabel.text = "Error fetching fact."

# Handle the HTTPRequest completion
func _on_request_completed(result, response_code, headers, body, request):
	if response_code == 200:
		$FactLabel.text = body.get_string_from_utf8()
	else:
		$FactLabel.text = "Error fetching fact."
	
	request.queue_free()  # Free request node after use

# Preload images into memory for fast execution
func preload_images():
	for path in image_paths:
		var image = load(path)
		if image:
			preloaded_images[path] = image
		else:
			print("Failed to load image:", path)

	# Simulate loading completion
	loading_complete = true
	show_continue_message()

# Show "Press anywhere to continue" message with breathing effect
func show_continue_message():
	loading_label.text = "Press anywhere to continue"
	
	# Create a breathing (pulsating) effect
	tween.tween_property(loading_label, "modulate:a", 0.3, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(loading_label, "modulate:a", 1, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()  # Infinite loop for breathing effect

# Detect user input to continue
func _input(event):
	if loading_complete and event is InputEventMouseButton and event.pressed:
		proceed_to_main_menu()

# Load the main menu scene
func proceed_to_main_menu():
	get_tree().change_scene_to_file("res://main_menu.tscn")
