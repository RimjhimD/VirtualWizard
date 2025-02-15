extends Control

func _ready():
	$LoadingTimer.start()

func _on_loading_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
