extends KinematicBody2D

# node references
onready var player = $'..'



# constants
const SPEED = 15
const MAX_BOUNCES = 1



# member variables
var shot_trajectory
var is_propelling = true
var bounces = 0



func _ready():
	set_physics_process(true)
	shot_trajectory = (get_global_mouse_position() - self.global_position).normalized()
	set_as_toplevel(true)
# end _ready



func _physics_process(delta):
	if bounces > MAX_BOUNCES:
		player.is_shot_active = false
		queue_free()
	
	if is_propelling:
		var collision = move_and_collide(shot_trajectory * SPEED, true)
		if collision:
			if not bounces == MAX_BOUNCES:
				player.on_shot_bounce()
			
			shot_trajectory = shot_trajectory.bounce(collision.normal)
			bounces += 1
	else:
		print('retrieving shot')
		shot_trajectory = self.position.direction_to(player.position)
		var collision = move_and_collide(shot_trajectory * SPEED, true)
		if collision and 'Player' in collision.get_collider().name:
			print('shot collected')
			player.is_shot_active = false
			queue_free()
# end _physics_process
