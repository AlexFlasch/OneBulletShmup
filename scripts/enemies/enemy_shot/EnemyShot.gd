extends KinematicBody2D



# node references
onready var player = $'../../Player'



# constants
const SPEED = 2



# member variables
var direction = Vector2(0, 0)



func _ready():
	pass # Replace with function body.
# end _ready



func _process(delta):
	var collision = move_and_collide(direction * SPEED)
	
	if collision:
		handle_collision(collision)
# end _process



func set_direction(dir):
	direction = dir
# end _process



func kill():
	queue_free()



func handle_collision(collision):
	var collider = collision.get_collider()
	
	if 'Player' in collider.name:
		player.kill()
	
	kill()
# end handle_collision