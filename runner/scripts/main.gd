extends Node2D
@onready var fire_animation: AnimatedSprite2D = $Fire
@onready var vine_area: StaticBody2D = $Vine

@onready var bg_music = $"/root/BackgroundMusic"
@onready var game_over_sound = $GameOverSound
@onready var gem_pickup_sound = $GemPickupSound




# preload obstacle scenes
var platform_scene = preload("res://scenes/platform.tscn")
@onready var vine_scene = preload("res://scenes/vine.tscn")
@onready var spike_scene = preload("res://scenes/spike_obs.tscn")
@onready var fire_scene = preload("res://scenes/fire_obstacle.tscn")
@onready var rock_pillar_scene = preload("res://scenes/rock_pillar.tscn")
@onready var rock_pillar_tandb_scene = preload("res://scenes/rock_pillar_t_and_b.tscn")
@onready var gem = preload("res://scenes/gem.tscn")


#var obstacle_types := [rock_scene,rock_scene,rock_scene]
#var obstacles : Array = []
# Obstacle Variables
var last_obs
var top_rocks : Array = []
#var bottom_spikes : Array = []
var obstacles = Global.obstacles

# Game component variables
const ECHO_START_POS := Vector2(150, 485)
const CAM_START_POS := Vector2(576, 324)
var screen_size : Vector2
var ground_height : int
var ceiling_height : int
var game_running : bool

#obstacle detection vars
@onready var player_position: Node2D = $Echo
@onready var top_rock : RigidBody2D

# score variables
var score : int
var SCORE_MODIFIER : int = 10
var high_score: int

# Physics variables
var speed : float
const START_SPEED : float = 8.0
const MAX_SPEED : int = 15
const SPEED_MODIFIER : int = 12000
var push_distance: float = 800.0 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	ceiling_height = $Ceiling.get_node("Sprite2D").texture.get_height()

	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()
	
func new_game():
	#Start Game in paused state and allows user to press space to start
	# get rid of all game pausing stuff later
	get_tree().paused = false
	score = 0
	show_score()
	game_running = false
	
	# Clear obstacles array to start a new game with fresh obstacles
	for obs in obstacles:
		if is_instance_valid(obs):
			obs.queue_free()
	obstacles.clear()
	
	# Find position of each node
	$Echo.position = ECHO_START_POS 
	$Echo.velocity = Vector2(0,0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2(127,-623)
	$Ceiling.position = Vector2(129,-1237)
	$Background.scroll_offset = Vector2(0,0)
	
	# Hide User Interface nodes and show instructions and return button
	$HUD.get_node("StartLabel").show()
	$HUD.get_node("Return").show()
	
	$GameOver.get_node("ScoreTitle").hide()
	$GameOver.get_node("ScoreCount").hide()
	$GameOver.get_node("Button").hide()
	
	
	last_obs = null # Reset last_obs
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

# get rid of if statment later so the game does not pause
# If game is running, calculate speed based on where you are at with the score.
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		#Generate obstacles when game is proccessing
		generate_obs()
		
		#Spawn gems
		spawn_gem()
		
		# Calculates the camera and player position to match the speed
		$Echo.position.x += speed
		$Camera2D.position.x += speed

		# starts gem spawner
		$GemSpawnTimer.start()
		
		# update score
		score += speed
		show_score()
		# repeat backgrounds
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x 
		if $Camera2D.position.x - $Ceiling.position.x > screen_size.x * 1.5:
			$Ceiling.position.x += screen_size.x 
		if $Camera2D.position.x - $Background.scroll_offset.x > screen_size.x * 1.5:
			$Background.scroll_offset.x += screen_size.x
		
		 
	else:
		if Input.is_action_just_pressed("ui_accept"):
			game_running = true
			# get rid of this later
			$HUD.get_node("HBOX").show()
			$HUD.get_node("StartLabel").hide()
			$HUD.get_node("Return").hide()


	game_over()

# game over function that pauses game, shows scores, and allows you to restart
func game_over():
	
	check_high_score()
	#reset hud and gameover screen
	# Calculate the visible area based on the camera position
	var camera_left_boundary = $Camera2D.position.x - screen_size.x / 2
	var camera_right_boundary = $Camera2D.position.x + screen_size.x / 2

	# Check if the Echo is out of the visible area
	if $Echo.position.x < camera_left_boundary or $Echo.position.x > camera_right_boundary:
		get_tree().paused = true  # Pause the game
		if get_tree().paused == true:
			$HUD.get_node("HBOX").hide()
			$GameOver.get_node("Button").show()
			$GameOver.get_node("ScoreTitle").show()
			$GameOver.get_node("ScoreCount").show()
			$GameOver.get_node("ScoreCount").text = str(score / SCORE_MODIFIER)
			game_over_sound.play()
			print("game over")
	
func generate_obs():
	#clean up invalid obstacles
	obstacles = obstacles.filter(is_instance_valid)
	
	# Ensure to generate rocks at appropriate intervals
	if last_obs == null or (is_instance_valid(last_obs) and last_obs.position.x < score + randi_range(300, 500)):
		var obstacle_type = randi_range(0, 3)
		
		var obs
		var obs_x : int = $Camera2D.position.x + screen_size.x + randi_range(200, 400)
		
		if obstacle_type == 0:
			var pillar = rock_pillar_scene.instantiate()
			var obs_y = ground_height
			pillar.position = Vector2(obs_x, obs_y)
			add_child(pillar)
			obstacles.append(pillar)
			
			var spikes = rock_pillar_tandb_scene.instantiate()
			spikes.position = Vector2(obs_x, obs_y)
			add_child(spikes)
			obstacles.append(spikes)
			
			last_obs = pillar
		
		else:
			if obstacle_type == 1: #Vine
				obs = vine_scene.instantiate()
				obs.add_to_group("vine")
				add_child(obs)
				var obs_height = obs.get_node("Sprite2D").texture.get_height()
				var obs_y : int = ceiling_height #position near ceiling
			
				add_obs(obs, obs_x, obs_y)
			
			#elif obstacle_type == 2: #Platform
				#obs = platform_scene.instantiate()
				#var obs_height = obs.get_node("Sprite2D").texture.get_height()
				#var obs_scale = obs.get_node("Sprite2D").scale
				#var obs_y : int = (screen_size.y - ground_height - ceiling_height) / 1.83 - obs_height / 3
			
				#add_obs(obs, obs_x, obs_y)
		
			elif obstacle_type == 2: #Spikes
				obs = spike_scene.instantiate()
				obs.add_to_group("Spikes_obs")
				var obs_height = obs.get_node("Stalagmites").texture.get_height()
				var obs_scale = obs.get_node("Stalactites").scale
				var obs_y : int = ground_height
				obs.connect("game_over_triggered", Callable(self, "instant_game_over"))
			
				add_obs(obs, obs_x, obs_y)
		
			elif obstacle_type == 3: #flames/fire obstacle
				obs = fire_scene.instantiate()
				obs.add_to_group("Fire_obs")
				obs.get_node("FireObstacle").play()
				#hardcoded y-location, will have to readjust after sprite change
				var obs_y : int = 294
				obs.connect("game_over_triggered", Callable(self, "instant_game_over"))

			
				add_obs(obs, obs_x, obs_y)		

			last_obs = obs
		

func add_obs(obs, x, y):
		obs.position = Vector2(x, y)
		add_child(obs)
		obstacles.append(obs)
		

func is_near_rock(rock: RigidBody2D) -> bool:
	var distance_to_rock = player_position.global_position.distance_to(rock.global_position)
	print("Distance to boulder:", distance_to_rock)  # Debugging output
	print("Player Position:", player_position.global_position)  # Debugging output
	print("Rock Position:", rock.global_position)  # Debugging output
	return distance_to_rock <= push_distance

func show_score():
	$HUD.get_node("ScoreLayer").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score/SCORE_MODIFIER) 


# spawns gems at random positions at a 5 second interval
func _on_gem_spawn_timer_timeout() -> void:
	# NOTE: code only works once you restart the game after dying once
	#		problem with line 290
	
	# var gem = gemstone_scene.instantiate()
	# var gem_location = $GemSpawnPath/GemSpawnPathFollow
	# gem_location.progress_ratio = randf()
	# gem.position = gem_location
	# add_child(gem)
	
	print("gem spawned")

#Game over function for instant death obstacles like fire_obs or spikes
func instant_game_over() -> void:
	print("Game over by insta death")
	get_tree().paused = true
	$GameOver.get_node("Button").show()
	$GameOver.get_node("ScoreTitle").show()
	$GameOver.get_node("ScoreCount").show()
	$GameOver.get_node("ScoreCount").text = str(score / SCORE_MODIFIER)
	game_over_sound.play()
	
#func spawn_gems():
	#for i in range(5):
		#var g = gem.instantiate()
		#$GemContainer.add_child(g)
		#g.screensize = screen_size
		#g.position =Vector2(randf_range(0, screen_size.x), (randf_range(0, screen_size.y)))

#func spawn_gems():
	#for i in range(5):
		#var g = gem.instantiate()
		#$GemContainer.add_child(g)
		##g.screensize = screen_size
		#g.position = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))

#func spawn_gem():
	#var camera_x = $Camera2D.position.x
	#var ground_line = screen_size.y - ground_height
	#var gem_y_position = ground_line - 50
	#var spawn_x = camera_x + screen_size.x + 200
#
	#var g = gem.instantiate()
	#$GemContainer.add_child(g) # or add_child(g) if you're adding directly to the main scene
	#g.position = Vector2(spawn_x, gem_y_position)
#
	## Connect the gem's pickup signal to the _on_gem_picked_up function in this main script
	##g.gem_picked_up.connect(Callable(self, "_on_gem_picked_up"))

var gem_scene = preload("res://scenes/gem.tscn")
var next_gem_x = 0
var min_spacing = 200
var max_spacing = 500

func spawn_gem():
	# Assume camera_x is the current camera position
	var camera_x = $Camera2D.position.x

	# Move the next_gem_x ahead of the camera view, plus random spacing
	# Ensure next_gem_x always stays ahead of the camera
	if next_gem_x < camera_x + get_window().size.x:
		next_gem_x = camera_x + get_window().size.x + 100

	# Add random spacing to the next gem position
	next_gem_x += randi_range(min_spacing, max_spacing)

	# Determine vertical position near ground.
	var ground_line = screen_size.y - ground_height
	# If you want them all at ground_line - 50:
	var base_y = ground_line - 100

	# If you want a slight random vertical offset (optional):
	var gem_y = base_y + randi_range(-40, -400) # vary position by ±30 pixels

	# Instantiate the gem
	var g = gem_scene.instantiate()
	add_child(g)
	g.position = Vector2(next_gem_x, gem_y)

	# Connect the pickup signal 
	
func _on_gem_picked_up():
	gem_pickup_sound.play()
	#print("Gem picked up!") # For debugging
	score += SCORE_MODIFIER
	show_score()
	


			
