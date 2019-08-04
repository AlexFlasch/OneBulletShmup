extends KinematicBody2D

# node references
onready var player = $'..'



# constants
const SPEED = 35000



# member variables
var shot_trajectory
var is_propelling = true
var bounces = 0



func _ready():
	set_physics_process(true)
	shot_trajectory = player.position.direction_to(get_local_mouse_position())
	set_as_toplevel(true)
# end _ready



func _physics_process(delta):
	if is_propelling:
		var collision = move_and_collide(shot_trajectory, true)
	else:
		shot_trajectory = self.position.angle_to(player.position)
# end _physics_process
