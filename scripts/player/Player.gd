extends KinematicBody2D

# node references
onready var reticle_sprite = $ReticleSprite
onready var player_sprite = $PlayerSprite
onready var player_collider = $PlayerCollider
onready var player_propel_sound = $PlayerPropel
onready var player_shoot_sound = $PlayerShoot
onready var player_death_sound = $PlayerDeath
onready var shot_bounce_sound = $ShotBounce
onready var shot_retrieve_sound = $ShotRetrieve
onready var shot_dissipate_sound = $ShotDissipate
onready var shot_ready_light = $ShotReadyLight
onready var shot_cooldown_timer = $ShotCooldown
onready var shot_dissipate_cooldown_timer = $ShotDissipateCooldown
onready var deletion_timer = $DeletionTimer
onready var player_camera = $Pivot/CameraOffset/PlayerCamera
onready var explosion_particles = $ExplosionParticles
var player_shot = load('res://scripts/Player/PlayerShot.tscn')



# constants
const MAX_SPEED = 25000
const ACCELERATION = 56000
const DECELERATION = 70000
const CHARGED_SPRITE = preload('res://assets/player/sprites/idle charged.png')
const UNCHARGED_SPRITE = preload('res://assets/player/sprites/idle uncharged.png')



# member variables
var is_alive = true
var speed = 0
var velocity = Vector2()
var last_direction = Vector2()
var is_shot_active = false
var is_shot_dissipated = false
var shot_instance
var is_blink_active = false



# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)
#end _ready



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_alive:
		get_input(delta)
		move_and_slide(velocity * delta)
# end _physics_process



func _process(delta):
	if is_blink_active and not is_shot_active:
		player_sprite.self_modulate = Color(0.5, 1.0, 0.5, 1)
	else:
		player_sprite.self_modulate = Color(1.0, 1.0, 1.0, 1)
	
	var mouse_rotation = get_local_mouse_position().angle() + deg2rad(90)
	reticle_sprite.rotation = mouse_rotation
	player_sprite.rotation = mouse_rotation
	
	# change sprite if the player has the shot out
	if is_shot_active:
		player_sprite.texture = UNCHARGED_SPRITE
	else:
		player_sprite.texture = CHARGED_SPRITE
	
	if not is_alive:
		shot_ready_light.energy = 0
# end _process



func get_input(delta):
	# movement input
	if last_direction:
		velocity = last_direction
	
	var no_direction_pressed = (
		not Input.is_action_pressed('ui_up') and
		not Input.is_action_pressed('ui_down') and
		not Input.is_action_pressed('ui_left') and
		not Input.is_action_pressed('ui_right')
	)
	
	if Input.is_action_pressed('ui_up'):
		last_direction = Vector2.UP
		velocity += Vector2.UP
	
	if Input.is_action_pressed('ui_down'):
		last_direction = Vector2.DOWN
		velocity += Vector2.DOWN
	
	if Input.is_action_pressed('ui_left'):
		last_direction = Vector2.LEFT
		velocity += Vector2.LEFT
	
	if Input.is_action_pressed('ui_right'):
		last_direction = Vector2.RIGHT
		velocity += Vector2.RIGHT
	
	if not no_direction_pressed:
		speed += ACCELERATION * delta
		if not player_propel_sound.playing:
			player_propel_sound.play()
	else:
		speed -= DECELERATION * delta
		player_propel_sound.stop()
	
	# calculate movement velocity
	speed = clamp(speed, 0, MAX_SPEED)
	velocity = velocity.normalized() * speed
	
	# mouse input
	if Input.is_action_just_pressed('shoot'):
		if not is_shot_active:
			propel_shot()
		else:
			retrieve_shot()
# end get_input



func kill():
	is_alive = false
	player_death_sound.play()
	deletion_timer.start()
	reticle_sprite.visible = false
	player_sprite.visible = false
	explosion_particles.emitting = true
	shot_ready_light.energy = 0
	player_collider.disabled = true
# end kill



func propel_shot():
	if not is_shot_active and not is_shot_dissipated:
		shot_ready_light.energy = 0.01
		is_shot_active = true
		shot_instance = player_shot.instance()
		player_shoot_sound.play()
		
		
		shot_instance.set_name('shot')
		
		add_child(shot_instance)
# end propel_shot



func retrieve_shot():
	if shot_instance and not is_shot_dissipated:
		# make sure the user can't spam themselves with the retrieve sound
		if shot_instance.is_propelling:
			shot_retrieve_sound.play()
		shot_instance.is_propelling = false
# end retrieve_shot



func on_enemy_kill():
	player_camera.shake_screen()
# end on_enemy_kill



func on_shot_bounce():
	shot_bounce_sound.play()
# end on_shot_bounce



func on_shot_dissipate():
	shot_ready_light.energy = 0
	shot_dissipate_sound.play()
	is_shot_active = false
	is_shot_dissipated = true
	shot_dissipate_cooldown_timer.start()
# end on_shot_dissipate



func on_shot_retrieved():
	shot_cooldown_timer.start()
	is_shot_dissipated = true
# end on_shot_retrieved



func _on_ShotCooldown_timeout():
	is_shot_dissipated = false
	shot_ready_light.energy = 1
# end on_ShotCooldown_timeout



func _on_ShotDissipateCooldown_timeout():
	is_shot_dissipated = false
	shot_ready_light.energy = 1
# end _on_ShotCooldown_timeout



func on_enemy_collide():
	pass
# end on_enemy_collide



func _on_DeletionTimer_timeout():
	get_tree().paused = true
# end _on_DeletionTimer_timeout
