extends KinematicBody2D

# node references
var enemy_shot = load('res://scripts/enemies/enemy_shot/EnemyShot.tscn')
onready var shot_cooldown_timer = $ShotCooldown
onready var shot_sound = $ShotSound
onready var death_sound = $DeathSound
onready var deletion_timer = $DeletionTimer
onready var strafer_sprite = $StraferSprite
onready var propulsion_particles = $PropulsionParticles
onready var explostion_particles = $ExplosionParticles
onready var player = $'../../Player'
onready var invincibility_timer = $InvincibilityTimer



# constants
const SPEED = 100
const DISTANCE_TO_MAINTAIN = 200
const BIG_BAD_SPRITE = preload('res://assets/enemies/strafer/Strafer2.png')



# member variables
var hp = 1
var direction
var distance_to_player
var is_big_bad = false
var is_invincible = false



func _init(is_big_bad = false):
	self.is_big_bad = is_big_bad



func _ready():
	direction = self.global_position.direction_to(player.global_position)
	
	if is_big_bad:
		upgrade()
# end _ready



func _process(delta):
	if is_invincible:
		$StraferCollider.disabled = true
	elif not is_invincible and hp > 0:
		$StraferCollider.disabled = false
	
	distance_to_player = self.global_position.distance_to(player.global_position)
	self.rotation = self.global_position.direction_to(player.global_position).angle() + deg2rad(90)
	
	var collision
	
	if distance_to_player <= DISTANCE_TO_MAINTAIN:
		collision = strafe(delta)
	else:
		collision = move_and_collide(direction * SPEED * delta)
	
	direction = self.global_position.direction_to(player.global_position)
	
	if collision:
		handle_collision(collision)
# end _process



func handle_collision(collision):
	var collider = collision.get_collider()
	
	if 'Player' in collider.name:
		player.kill()
		kill()
# end handle_collision



func upgrade():
	hp = 2
	strafer_sprite.set_texture(load('res://assets/enemies/strafer/Strafer2.png'))
# end upgrade



func strafe(delta):
	var move_away = (DISTANCE_TO_MAINTAIN - distance_to_player) > 5
	var direction_to_player = self.global_position.direction_to(player.global_position)
	
	var strafe_vector = direction_to_player.rotated(deg2rad(90)).normalized()
	
	if move_away:
		strafe_vector = (strafe_vector + direction_to_player.rotated(deg2rad(180))).normalized()
	
	return move_and_collide(strafe_vector * SPEED * delta)
# end strafe



func fire_shot():
	var shot_direction = self.global_position.direction_to(player.global_position)
	var enemy_shot_instance = enemy_shot.instance()
	var offset = self.global_position.direction_to(player.global_position) * 25
	enemy_shot_instance.global_position = self.global_position + offset
	enemy_shot_instance.set_direction(shot_direction)
	
	get_parent().add_child(enemy_shot_instance)
	shot_sound.play()
# end fire_shot



func hit():
	hp -= 1
	
	print('hp: ' + str(hp))
	
	is_invincible = true
	invincibility_timer.start()
	
	if hp <= 0:
		kill()
# end hit



func kill():
	self.collision_layer = 20
	shot_cooldown_timer.stop()
	strafer_sprite.visible = false
	$StraferCollider.disabled = true
	explostion_particles.emitting = true
	propulsion_particles.emitting = false
	death_sound.play()
	deletion_timer.start()
# end kill



func _on_ShotCooldown_timeout():
	fire_shot()
# end _on_ShotCooldown_timeout



func _on_DeletionTimer_timeout():
	queue_free()
# end _on_DeletionTimer_timeout



func _on_InvincibilityTimer_timeout():
	is_invincible = false
