extends KinematicBody2D

# node references
var enemy_shot = load('res://scripts/enemies/enemy_shot/EnemyShot.tscn')
onready var shot_cooldown_timer = $ShotCooldown
onready var shot_sound = $ShotSound
onready var death_sound = $DeathSound
onready var deletion_timer = $DeletionTimer
onready var long_range_sprite = $LongRangeSprite
onready var explostion_particles = $ExplosionParticles
onready var invincibility_timer = $InvincibilityTimer
onready var player = $'../../Player'



# constants
const SPEED = 1
const BIG_BAD_SPRITE = preload('res://assets/enemies/long_range/LongRange2.png')



# member variables
var direction
var hp = 1
var is_big_bad = false
var is_invincible = false



func _init(is_big_bad = false):
	self.is_big_bad = is_big_bad



func _ready():
	change_direction()
	
	if is_big_bad:
		upgrade()
# end _ready



func _process(delta):
	if is_invincible:
		$LongRangeCollision.disabled = true
	elif not is_invincible and hp > 0:
		$LongRangeCollision.disabled = false
	
	self.rotation = self.global_position.direction_to(player.global_position).angle() + deg2rad(-90)
	var collision = move_and_collide(direction * SPEED)
	
	if collision:
		handle_collision(collision)
# end _process



func upgrade():
	long_range_sprite.set_texture(load('res://assets/enemies/long_range/LongRange2.png'))
	hp = 2
# end upgrade



func handle_collision(collision):
	var collider = collision.get_collider()
	
	if 'Player' in collider.name:
		player.kill()
		kill()
# end handle_collision



func fire_shot():
	var shot_direction = self.global_position.direction_to(player.global_position)
	var enemy_shot_instance = enemy_shot.instance()
	var offset = self.global_position.direction_to(player.global_position) * 25
	enemy_shot_instance.global_position = self.global_position + offset
	enemy_shot_instance.set_direction(shot_direction)
	
	get_parent().add_child(enemy_shot_instance)
	shot_sound.play()
# end fire_shot



func change_direction():
	direction = Vector2(rand_range(-10, 10), rand_range(-10, 10)).normalized()
# end change_direction



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
	long_range_sprite.visible = false
	$LongRangeCollision.disabled = true
	explostion_particles.emitting = true
	death_sound.play()
	deletion_timer.start()
# end kill



func _on_ShotCooldown_timeout():
	fire_shot()
# end _on_ShotCooldown_timeout



func _on_DirectionChange_timeout():
	change_direction()
# end _on_DirectionChange_timeout



func _on_DeletionTimer_timeout():
	queue_free()
# end _on_DeletionTimer_timeout

func _on_InvincibilityTimer_timeout():
	is_invincible = false
