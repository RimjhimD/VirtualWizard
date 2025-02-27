extends Control

# UI elements
@onready var email_input = $VBoxContainer/EmailInput
@onready var password_input = $VBoxContainer/PasswordInput
@onready var status_label = $VBoxContainer/StatusLabel
@onready var login_button = $VBoxContainer/LoginButton
@onready var signup_button = $VBoxContainer/SignupButton
@onready var back_button = $BackButton

# Firebase references
var auth: FirebaseAuth
var database: FirebaseDatabase

func _ready():
	# Initialize Firebase
	auth = Firebase.Auth
	database = Firebase.Database
	
	# Connect Firebase signals
	auth.connect("login_succeeded", _on_firebase_auth_result.bind(true))
	auth.connect("login_failed", _on_firebase_auth_result.bind(false))
	auth.connect("signup_succeeded", _on_firebase_auth_result.bind(true))
	auth.connect("signup_failed", _on_firebase_auth_result.bind(false))
	
	# Connect button signals
	login_button.pressed.connect(_on_login_button_pressed)
	signup_button.pressed.connect(_on_signup_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

# Function to handle login
func _on_login_button_pressed():
	var email = email_input.text
	var password = password_input.text
	
	if email.is_empty() or password.is_empty():
		status_label.text = "Please enter email and password."
		return
	
	# Authenticate with Firebase
	auth.login_with_email_and_password(email, password)

# Function to handle signup
func _on_signup_button_pressed():
	var email = email_input.text
	var password = password_input.text
	
	if email.is_empty() or password.is_empty():
		status_label.text = "Please enter email and password."
		return
	
	# Check if email is valid
	if not email.is_valid_email():
		status_label.text = "Invalid email format."
		return
	
	# Sign up with Firebase
	auth.signup_with_email_and_password(email, password)

# Function to handle Firebase authentication results
func _on_firebase_auth_result(result: bool, message: String, data: Dictionary):
	if result:
		status_label.text = "Success: " + message
		# Save user data to Firebase Realtime Database
		save_user_data(data.local_id, email_input.text)
	else:
		status_label.text = "Error: " + message

# Function to save user data to Firebase Realtime Database
func save_user_data(user_id: String, email: String):
	var user_data = {
		"email": email
	}
	
	database.set_data("users/" + user_id, user_data)

# Function to go back to the Options screen
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://options_screen.tscn")
