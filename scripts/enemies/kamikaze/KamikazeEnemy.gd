extends KinematicBody2D

# node references
onready var player = $'../../Player'
onready var kamikaze_sprite = $KamikazeSprite
onready var preparation_sound = $AtackPreparationSound
onready var death_sound = $KamikazeDeath
onready var deletion_timer = $DeletionTimer
onready var preparation_timer = $AttackPreparationTimer
onready var preparation_tween = $AttackPreparationTween
onready var attack_tween = $AttackTween
onready var attack_cooldown_timer = $AttackCooldownTimer
onready var explosion_particles = $ExplosionParticles
onready var invincibility_timer = $InvincibilityTimer


# constants
const SPEED = 1
const ATTACK_SPEED = 2
const BIG_BAD_SPRITE = preload("res://assets/enemies/kamikaze/Kamikaze2.png")



# member variables
var hp = 1
var distance_to_player
var is_preparing_attack = false
var player_attack_pos
var is_attack_in_cooldown = false
var is_big_bad = false
var is_invincible = false



func _init(is_big_bad = false):
	self.is_big_bad = is_big_bad



func _ready():
	player_attack_pos = player.position
	preparation_tween.interpolate_method(self, 'preparation_color_tween', 0, 100, 1.5, Tween.TRANS_SINE, Tween.EASE_OUT)
#	attack_tween.interpolate_method(self, 'attack', self.position, player_attack_pos, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
#	attack_tween.interpolate_property(self, 'position', self.position, player_attack_pos, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN)

	if is_big_bad:
		upgrade()
# end _ready



func _process(delta):
	if is_invincible:
		$KamikazeCollision.disabled = true
	elif not is_invincible and hp > 0:
		$KamikazeCollision.disabled = false
	
	attack_tween.interpolate_property(self, 'position', self.position, player_attack_pos, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN)
	
	distance_to_player = self.global_position.distance_to(player.global_position)
	var move_direction = self.global_position.direction_to(player.global_position)
	
	if not is_preparing_attack:
		self.rotation = self.global_position.direction_to(player.global_position).angle() + deg2rad(90)
		var collision = move_and_collide(move_direction * SPEED)
		
		# kill the player if colliding
		if collision and 'Player' in collision.get_collider().name:
			player.kill()
			hit()
	
#	if distance_to_player < 200 and not is_preparing_attack and not is_attack_in_cooldown:
#		prepare_attack()
# end _process



func upgrade():
	kamikaze_sprite.set_texture(load("res://assets/enemies/kamikaze/Kamikaze2.png"))
	hp = 2
# end upgrade



#func prepare_attack():
#	is_preparing_attack = true
#	preparation_sound.play()
#	preparation_timer.start()
#	preparation_tween.start()
# end prepare_attack



#func attack(value):
#	print(value)
#	var direction = self.global_position.direction_to(player_attack_pos).normalized()
#	print('new position: ' + str(value))
#	self.global_position = value
#	pass
# end attack



func preparation_color_tween(value):
	var color_value = (sin(value) / 2) + 0.5
	kamikaze_sprite.self_modulate = Color(1.0, color_value, color_value, 1.0)
# end preparation_color_tween



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
	kamikaze_sprite.visible = false
	$KamikazeCollision.disabled = true
	death_sound.play()
	explosion_particles.emitting = true
	deletion_timer.start()
# end kill



func _on_DeletionTimer_timeout():
	queue_free()
# end _on_DeletionTimer_timeout



func _on_AttackPreparationTimer_timeout():
	kamikaze_sprite.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	player_attack_pos = player.position
	print('my pos: ' + str(self.global_position) + ', player pos: ' + str(player_attack_pos))
	attack_tween.start()
# end _on_AttackPreparationTimer_timeout



func _on_AttackTween_tween_all_completed():
	is_attack_in_cooldown = true
	attack_cooldown_timer.start()
	is_preparing_attack = false
# end _on_AttackTween_tween_all_completed



func _on_AttackCooldownTimer_timeout():
	is_attack_in_cooldown = false
# end _on_AttackCooldownTimer_timeout



func _on_InvincibilityTimer_timeout():
	is_invincible = false
