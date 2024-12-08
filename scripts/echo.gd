extends CharacterBody2D


signal gem_count_changed(new_count: int)


# sprite variables
@onready var echo_sprite: AnimatedSprite2D = $Echo
@onready var earth_animation: AnimatedSprite2D = $Earth
@onready var fire_animation: AnimatedSprite2D = $Fire
@onready var water_animation: AnimatedSprite2D = $Water
@onready var air_animation: AnimatedSprite2D = $air
@onready var fire_sound = $fireslash
@onready var rock_sound = $rocksound
@onready var jump_sound = $jumpsound
@onready var air_sound = $airsound
@onready var water_sound = $watersound
@onready var gem_sound = $GemPickupSound

@onready var gem_label = $GemLabel


#Variables for the attacks and the obstacle signals
var can_attack: bool = true
@onready var attack_area: Area2D = $Ability_hitbox
@onready var attack_collision: CollisionShape2D = $Ability_hitbox/CollisionShape2D

@onready var player_area: Area2D = $Echo_hitbox

const ANIMATION_DURATION: float = 1.0 

#Jump variables
var GRAVITY : int = 4000
var JUMP_SPEED : int = -1275

#Double jump variables
var DOUBLE_JUMP_ON: bool = false
var DOUBLE_JUMP_GRAVITY : int = 2500
var DOUBLE_JUMP_SPEED : int  = -900

#Glide Variables
var GLIDE_GRAVITY: int = 1200
var GLIDE_X_SPEED: int = 2000

var gem_counter = 0

func _on_ready():
	#Adding to group "player". Used to have different interaction with fire and spike
	add_to_group("Player")
	print("Echo added to Player Group")
	
	earth_animation.visible = false
	fire_animation.visible = false
	attack_area.monitoring = false
	attack_collision.disabled = true


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor(): #Normal Jump
			jump_sound.play()
			velocity.y = JUMP_SPEED
			echo_sprite.play("jump")
		elif not DOUBLE_JUMP_ON: #Double Jump
			air_sound.play()
			air_animation.visible = true
			air_animation.play("air")
			DOUBLE_JUMP_ON = true
			velocity.x = 200
			velocity.y = -800
			DOUBLE_JUMP_SPEED
			GRAVITY = DOUBLE_JUMP_GRAVITY
			_hide_animation()
	
	else:
		velocity.x = 0
		if Input.is_action_just_pressed("earth"):
			#earth_push_perform()
			perform_attack()
			earth_animation.visible = true
			echo_sprite.play("cast")
			earth_animation.play("earth")
			knock_over_rocks()
			rock_sound.play()
			# Start a coroutine to hide the earth animation after a delay
			_hide_animation()
			#hide other casting animations
			water_animation.visible = false
			fire_animation.visible = false
		
		#Fire Slash button
		elif Input.is_action_just_pressed("fire"):
			#perform_fire_attack()
			perform_attack()
			fire_animation.visible = true
			echo_sprite.play("cast")
			fire_animation.play("fire")
			fire_sound.play()
			_hide_animation()
			#hide other casting animations
			water_animation.visible = false
			earth_animation.visible = false
			
		#Water Wall button
		elif Input.is_action_just_pressed("water"):
			#water_attack_perform()
			perform_attack()
			water_animation.visible = true
			echo_sprite.play("cast")
			water_animation.play("waterwall")
			water_sound.play()
			_hide_animation()
			#hide other casting animations
			fire_animation.visible = false
			earth_animation.visible = false


		
	# Add the gravity.
	velocity.y += GRAVITY * delta
	# Handle jump.
	if is_on_floor():
		#Remove double jump when landing
		DOUBLE_JUMP_ON = false
		GRAVITY = 3000
		JUMP_SPEED = -1275
		
		if not get_parent().game_running:
			echo_sprite.play("idle")
		else:
			$RunCol.disabled = false
			if Input.is_action_pressed("ui_accept"):
				jump_sound.play()
				velocity.y = JUMP_SPEED
			elif Input.is_action_pressed("air"):
				air_sound.play()
			else:
				echo_sprite.play("run")
	else:
			echo_sprite.play("jump")
	if Input.is_action_just_pressed("knock_over"):
		knock_over_rocks()
	move_and_slide()

func _on_area_2d_body_entered(body):
	if body.is_in_group("RigidBody"):
		body.collision_layer = 1
		body.collision_mask = 1
		
func _on_area_2d_body_exited(body):
		body.collision_layer = 1
		body.collision_mask = 1
		
func knock_over_rocks():
	var obstacles = Global.obstacles

	# Assuming the rocks are stored in an array called 'obstacles'
	for rock in obstacles:
		if is_instance_valid(rock) and rock is RigidBody2D:
			# Apply a force to each rock to knock it over
			var force = Vector2(randf_range(-300, 300), -500) # Random direction with upward push
			rock.apply_impulse(Vector2.ZERO, force)
	
func _hide_animation() -> void:
	if Input.is_action_just_pressed("earth"):
		await get_tree().create_timer(ANIMATION_DURATION).timeout
		earth_animation.visible = false
	elif Input.is_action_just_pressed("fire"):
		await get_tree().create_timer(ANIMATION_DURATION).timeout
		fire_animation.visible = false
	elif Input.is_action_just_pressed("water"):
		await get_tree().create_timer(ANIMATION_DURATION).timeout
		water_animation.visible = false
	elif Input.is_action_just_pressed("ui_accept"):
		await get_tree().create_timer(ANIMATION_DURATION).timeout
		air_animation.visible = false

func perform_attack():
	if can_attack:
		can_attack = false
		attack_area.monitoring = true
		attack_collision.disabled = false
		attack_area.visible = true
		if Input.is_action_just_pressed("earth"):
			attack_area.add_to_group("Earth_push")
		elif Input.is_action_just_pressed("fire"):
			attack_area.add_to_group("Fire_Attack")
		elif Input.is_action_just_pressed("water"):
			attack_area.add_to_group("Water_Attack")
		_hide_attack_area()

#Hides the activated hitboxes after use
func _hide_attack_area() -> void:
	await get_tree().create_timer(0.2).timeout
	attack_area.monitoring = false
	attack_collision.disabled = true
	attack_area.visible = false
	attack_area.remove_from_group("Fire_Attack")
	attack_area.remove_from_group("Water_Attack")
	attack_area.remove_from_group("Earth_push")
	can_attack = true


func _on_echo_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Fire_obs"):
		print("Player burnt to a crisp")
	elif area.is_in_group("Spikes_obs"):
		print("Player prickled from spikes")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("gem"):
		set_gem(gem_counter + 1)
		gem_sound.play()
		print(gem_counter)

func set_gem(new_gem_count: int) -> void:
	gem_counter = new_gem_count
	emit_signal("gem_count_changed", gem_counter)
