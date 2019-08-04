extends KinematicBody2D

# enums
enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

# node references
onready var reticle = $Reticle
onready var player_shoot_sound = $PlayerShoot
onready var player_death_sound = $PlayerDeath
onready var shot_bounce_sound = $ShotBounce
var player_shot = load('res://PlayerShot.tscn')



# constants
const MAX_SPEED = 25000
const ACCELERATION = 56000
const DECELERATION = 70000



# member variables
var pos = Vector2()
var speed = 0
var velocity = Vector2()
var last_direction = Vector2()
var is_shot_active = false
var shot_instance



# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)
#end _ready



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input(delta)
	move_and_slide(velocity * delta)
# end _physics_process



func _process(delta):
	reticle.rotation = get_local_mouse_position().angle() + deg2rad(90)
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
	else:
		speed -= DECELERATION * delta
	
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



func propel_shot():
	if not is_shot_active:
		is_shot_active = true
		shot_instance = player_shot.instance()
		player_shoot_sound.play()
		
		# offset shot spawn so it spawns in front of player's aim
		var offset = self.global_position.direction_to(get_global_mouse_position()) * 25
		
		shot_instance.set_name('shot')
		shot_instance.global_position += offset
		add_child(shot_instance)
# end propel_shot



func retrieve_shot():
	if shot_instance:
		shot_instance.is_propelling = false
# end retrieve_shot



func on_shot_bounce():
	shot_bounce_sound.play()
# end on_shot_bounce
