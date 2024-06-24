extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game
signal replay_clicked


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func show_message(text: String):
	$Gameplay/Message.text = text
	$Gameplay/Message.show()


func show_winner(winner_name: String):
	var text = winner_name + " won!"
	show_message(text)
	
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$Gameplay/ReplayButton.show()


func update_lap(current_lap, total_laps):
	var text = "Lap: " + str(current_lap) + "/" + str(total_laps)
	$Gameplay/LapLabel.text = text


func show_gameplay():
	$Background.hide()
	$TitleMenu.hide()
	$PauseMenu.hide()
	$Gameplay.show()


func stop_gameplay():
	$Gameplay.hide()
	get_tree().paused = true


func _on_play_button_pressed():
	show_gameplay()
	start_game.emit()


func _on_resume_button_pressed():
	show_gameplay()
	get_tree().paused = false


func _on_quit_button_pressed():
	get_tree().quit()


func _on_menu_button_pressed():
	stop_gameplay()
	$PauseMenu.hide()
	$TitleMenu.show()


func _on_pause_button_pressed():
	stop_gameplay()
	$Background.show()
	$PauseMenu.show()


func _on_replay_button_pressed():
	$Gameplay/ReplayButton.hide()
	replay_clicked.emit()


func _on_main_winner(winner_name):
	show_winner(winner_name)
