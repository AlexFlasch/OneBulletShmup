extends KinematicBody2D

# node references
var enemy_shot = load('res://scripts/enemies/enemy_shot/EnemyShot.tscn')
onready var shot_cooldown_timer = $ShotCooldown
onready var shot_sound = $ShotSound
onready var death_sound = $DeathSound
onready var deletion_timer = $DeletionTimer
onready var long_range_sprite = $LongRangeSprite
onready var explostion_particles = $ExplosionParticles
onready var player = $'../../Player'



# constants
const SPEED = 100



# member variables
var direction



func _ready():
	change_direction()
# end _ready



func _process(delta):
	self.rotation = self.global_position.direction_to(player.global_position).angle() + deg2rad(-90)
	move_and_slide(direction * SPEED)
# end _process


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



func kill():
	self.collision_layer = 20
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
	print('change direction happened')
	change_direction()
# end _on_DirectionChange_timeout



func _on_DeletionTimer_timeout():
	queue_free()
# end _on_DeletionTimer_timeout