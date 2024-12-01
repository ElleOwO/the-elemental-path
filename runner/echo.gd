extends CharacterBody2D

# sprite variables
@onready var echo_sprite: AnimatedSprite2D = $Echo
@onready var earth_animation: AnimatedSprite2D = $Earth
@onready var fire_animation: AnimatedSprite2D = $Fire
@onready var water_animation: AnimatedSprite2D = $Water
@onready var fire_sound = $fireslash
@onready var rock_sound = $rocksound
@onready var jump_sound = $jumpsound
@onready var air_sound = $airsound
@onready var water_sound = $watersound

var can_attack: bool = true
@onready var attack_area: Area2D = $Fire_slash_hitbox
@onready var attack_collision: CollisionShape2D = $Fire_slash_hitbox/CollisionShape2D


const ANIMATION_DURATION: float = 1.0 

var GRAVITY : int = 3000
const JUMP_SPEED : int = -1275


func _on_ready():
	earth_animation.visible = false
	fire_animation.visible = false
	attack_area.monitoring = false
	attack_collision.disabled = true


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("earth"):
		earth_animation.visible = true
		echo_sprite.play("cast")
		earth_animation.play("earth")
		knock_over_rocks()

		rock_sound.play()
		
		# Start a coroutine to hide the earth animation after a delay
		_hide_earth_animation()
	
	elif Input.is_action_just_pressed("fire"):
		perform_attack()
		fire_animation.visible = true
		echo_sprite.play("cast")
		fire_animation.play("fire")

		fire_sound.play()
		_hide_fire_animation()
		
	elif Input.is_action_just_pressed("water"):
		water_attack_perform()
		water_animation.visible = true
		echo_sprite.play("cast")
		water_animation.play("waterwall")
		water_sound.play()
		_hide_water_animation()

		
	# Add the gravity.
	velocity.y += GRAVITY * delta
	# Handle jump.
	if is_on_floor():
		if not get_parent().game_running:
			echo_sprite.play("idle")
		else:
			$RunCol.disabled = false
			if Input.is_action_pressed("ui_accept"):
				jump_sound.play()

				velocity.y = JUMP_SPEED
			elif Input.is_action_pressed("air"):
				air_sound.play()
				GRAVITY = 2000
				velocity.y = -900
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

func _hide_earth_animation() -> void:
	# Wait for the duration of the animation
	await get_tree().create_timer(ANIMATION_DURATION).timeout
	earth_animation.visible = false
	
func _hide_fire_animation() -> void:
	# Wait for the duration of the animation
	await get_tree().create_timer(ANIMATION_DURATION).timeout
	fire_animation.visible = false
	
	
func perform_attack():
	if can_attack:
		can_attack = false
		attack_area.monitoring = true
		attack_collision.disabled = false
		attack_area.visible = true
		attack_area.add_to_group("Fire_Attack")
		_hide_attack_area()

func water_attack_perform():
	if can_attack:
		can_attack = false
		attack_area.monitoring = true
		attack_collision.disabled = false
		attack_area.visible = true
		attack_area.add_to_group("Water_Attack")
		_hide_attack_area()

func _hide_attack_area() -> void:
	await get_tree().create_timer(ANIMATION_DURATION).timeout
	attack_area.monitoring = false
	attack_collision.disabled = true
	attack_area.visible = false
	can_attack = true

func _hide_water_animation() -> void:
	# Wait for the duration of the animation
	await get_tree().create_timer(ANIMATION_DURATION).timeout
	water_animation.visible = false
	
