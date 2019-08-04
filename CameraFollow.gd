extends Position2D

# node references
onready var player = $'..'
onready var camera_offset = $CameraOffset

# constants
const MAX_DISTANCE = 70

# member variables
var distance = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	update_pivot_angle()
#	update_pivot_distance()
# end _ready



func _physics_process(delta):
	update_pivot_angle()
#	update_pivot_distance()
# end _physics_process



func update_pivot_angle():
	rotation = player.velocity.angle()
# end update_pivot_angle



func update_pivot_distance():
	distance = lerp(distance, MAX_DISTANCE, player.speed / player.MAX_SPEED)
	
	var player_offset = Vector2(player.position.x + distance, player.position.y + distance)
	camera_offset.position = -1 * player_offset