extends Node2D



# node references
var kamikaze_enemy = load('res://scripts/enemies/kamikaze/KamikazeEnemy.tscn')
var longrange_enemy = load('res://scripts/enemies/long_range/LongRangeEnemy.tscn')
var strafer_enemy = load('res://scripts/enemies/strafer/StraferEnemy.tscn')
onready var score = $GUI/Score



# constants
const NORTH_BOUNDARY = -290
const EAST_BOUNDARY = 970
const SOUTH_BOUNDARY = 630
const WEST_BOUNDARY = -500



# member variables
var big_bads_spawned = 0



func _ready():
	pass
# end _ready



func _process(delta):
	if int(score.text) / 500 >= big_bads_spawned + 1:
		spawn_big_bad()
	
	if Input.is_action_just_pressed('restart'):
		get_tree().reload_current_scene()
# end _process



func _on_EnemySpawn_timeout():
	spawn_enemy()
# end _on_EnemySpawn_timeout



func generate_spawn_pos():
	return Vector2(rand_range(WEST_BOUNDARY, EAST_BOUNDARY), rand_range(NORTH_BOUNDARY, SOUTH_BOUNDARY))
# end generate_spawn_pos



func is_in_camera_boundaries(pos):
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	var collisions = space_state.intersect_point(pos)
	var is_within_camera_boundaries = false
	
	for intersection in collisions:
		var collider = intersection.collider
		
		if 'SpawnPreventionZone' in collider.name:
			is_within_camera_boundaries = true
			break
	
	return is_within_camera_boundaries
# end is_in_camera_boundaries



func get_random_enemy():
	var rand_int = floor(rand_range(0, 3))
	
	var rand_enemy
	if rand_int == 0:
		rand_enemy = kamikaze_enemy
	elif rand_int == 1:
		rand_enemy = longrange_enemy
	elif rand_int == 2:
		rand_enemy = strafer_enemy
	
	return rand_enemy
# end get_random_enemy



func spawn_enemy():
	var attempted_spawn_pos = generate_spawn_pos()
	
	while is_in_camera_boundaries(attempted_spawn_pos):
		attempted_spawn_pos = generate_spawn_pos()
	
	var new_enemy = get_random_enemy().instance()
	new_enemy.global_position = attempted_spawn_pos
	$Enemies.add_child(new_enemy)
# end spawn_enemy



func spawn_big_bad():
	big_bads_spawned += 1
	print('spawning big bad')
	
	var attempted_spawn_pos = generate_spawn_pos()
	
	while is_in_camera_boundaries(attempted_spawn_pos):
		attempted_spawn_pos = generate_spawn_pos()
	
	var new_enemy = get_random_enemy().instance()
	new_enemy._init(true)
	new_enemy.global_position = attempted_spawn_pos
	$Enemies.add_child(new_enemy)
# end spawn_big_bad