extends KinematicBody2D

# node references
onready var player = $'..'
onready var score = get_tree().root.get_node('World/GUI/Score')
var combo_counter = load('res://scripts/ComboText.tscn')



# constants
const SPEED = 15
const MAX_BOUNCES = 1
const PLAYER_COLLISION_MASK_BIT = 0



# member variables
var shot_trajectory
var is_propelling = true
var bounces = 0
var kills = 0



func _ready():
	set_physics_process(true)
	shot_trajectory = player.global_position.direction_to(get_global_mouse_position())
	set_as_toplevel(true)
# end _ready



func _physics_process(delta):
	if is_propelling:
		self.set_collision_mask_bit(PLAYER_COLLISION_MASK_BIT, false)
		var collision = move_and_collide(shot_trajectory * SPEED, true)
		if collision:
			handle_collision(collision)
	else:
		self.set_collision_mask_bit(PLAYER_COLLISION_MASK_BIT, true)
		shot_trajectory = self.global_position.direction_to(player.global_position)
		var collision = move_and_collide(shot_trajectory * SPEED, true)
		# check to make sure the player is the one collecting the shot
		if collision:
			handle_collision(collision, true)
# end _physics_process



func handle_collision(collision, is_retrieving = false):
	var collider = collision.get_collider()
	
	# handle collision types
	if 'Player' in collider.name and is_retrieving:
		player.is_shot_active = false
		player.on_shot_retrieved()
		queue_free()
	
	elif 'Enemy' in collider.name:
		player.on_enemy_kill()
		kills += 1
		display_combo_counter(collider.global_position)
		collider.kill()
		update_score()
		
	
	# bounce shot if necessary
	# only call on_shot_bounce if the shot isn't about to be deleted
	if not is_retrieving:
		if not bounces == MAX_BOUNCES:
			player.on_shot_bounce()
		else:
			player.on_shot_dissipate()
			queue_free()
		shot_trajectory = shot_trajectory.bounce(collision.normal)
		bounces += 1
# end handle_collision



func display_combo_counter(kill_pos):
	var combo_instance = combo_counter.instance()
	get_tree().root.get_node('World').add_child(combo_instance)
	combo_instance.global_position = kill_pos
	var combo_label = combo_instance.get_node('ComboLabel')
	
#	if kills > 1:
	combo_label.text = str(kills) + 'x'
	combo_label.visible = true
# end display_combo_counter



func update_score():
	var current_score = int(score.text)
	var updated_score = current_score + kills * 100
	score.text = str(updated_score)
# end update_score