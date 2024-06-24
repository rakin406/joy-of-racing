extends Node2D

# TODO: Reduce checkpoint signal function repetition.
# Apply DRY principle.

signal winner(winner_name: String)

@export var countdown = 3
@export var total_laps = 6 # TODO: Make this configurable ingame
var player_lap = 1
var opponent_lap = 1
var player_checkpoint = 0
var opponent_checkpoint = 0

# For opponent
var path: Path2D
var path_follow: PathFollow2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_size = get_viewport_rect().size
	
	# Resize race track to fit screen
	var race_track_size = $RaceTrack/Sprite2D.texture.get_size()
	#$RaceTrack.set_scale(screen_size / race_track_size)
	#scale = screen_size / race_track_size
	
	path = $OpponentPath
	path_follow = $OpponentPath/PathFollow2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func new_game():
	player_lap = 1
	opponent_lap = 1
	player_checkpoint = 0
	opponent_checkpoint = 0

	# Wait for countdown to start racing
	get_tree().paused = true

	# Default positions
	$Player.start($StartPosition.position)
	$Opponent.start($OpponentPosition.position)
	
	show_player_lap()
	
	# Start and show countdown
	for sec in range(countdown, 0, -1):
		$HUD.show_message(str(sec))
		# TODO: Make timer pausable without physics process running.
		await get_tree().create_timer(1.0).timeout
		
	$HUD.show_message("Go!")
	get_tree().paused = false
	await get_tree().create_timer(2.0).timeout
	$HUD/Gameplay/Message.hide()


## Display current player lap
func show_player_lap():
	$HUD.update_lap(player_lap, total_laps)


## Find the closest point on the path. This is for the opponent.
func get_path_direction(pos):
	var offset = path.curve.get_closest_offset(pos)
	path_follow.progress = offset
	return path_follow.transform.x


func _on_checkpoint_1_body_entered(body):
	if body == $Player and player_checkpoint == 0:
		player_checkpoint += 1
	elif body == $Opponent and opponent_checkpoint == 0:
		opponent_checkpoint += 1


func _on_checkpoint_2_body_entered(body):
	if body == $Player and player_checkpoint == 1:
		player_checkpoint += 1
	elif body == $Opponent and opponent_checkpoint == 1:
		opponent_checkpoint += 1


func _on_checkpoint_3_body_entered(body):
	if body == $Player and player_checkpoint == 2:
		player_checkpoint += 1
	elif body == $Opponent and opponent_checkpoint == 2:
		opponent_checkpoint += 1


func _on_finish_line_body_entered(body):
	# Refresh checkpoints and increment lap
	if body == $Player and player_checkpoint == 3:
		player_checkpoint = 0
		player_lap += 1
		
		# Player wins
		if player_lap > total_laps:
			# TODO: Find a way to get node name.
			winner.emit("Player")
			get_tree().paused = true
		# Show updated player lap
		elif player_lap <= total_laps:
			show_player_lap()
	elif body == $Opponent and opponent_checkpoint == 3:
		opponent_checkpoint = 0
		opponent_lap += 1
		
		# Opponent wins
		if opponent_lap > total_laps:
			winner.emit("Opponent")
			get_tree().paused = true


func _on_soundtrack_finished():
	$Soundtrack.play()
