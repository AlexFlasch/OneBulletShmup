extends Node2D



# node references
var kamikaze_enemy = load('res://scripts/enemies/kamikaze/KamikazeEnemy.tscn')
var longrange_enemy = load('res://scripts/enemies/long_range/LongRangeEnemy.tscn')



# constants
const NORTH_BOUNDARY = -290
const EAST_BOUNDARY = 970
const SOUTH_BOUNDARY = 630
const WEST_BOUNDARY = -500



func _ready():
	pass
# end _ready



func _process(delta):
	pass
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
		print('collider: ' + str(collider.name))
		
		if 'SpawnPreventionZone' in collider.name:
			is_within_camera_boundaries = true
			break
	
	return is_within_camera_boundaries
# end is_in_camera_boundaries



func get_random_enemy():
	var rand_int = floor(rand_range(0, 2))
	
	var rand_enemy
	if rand_int == 0:
		rand_enemy = kamikaze_enemy
	elif rand_int == 1:
		rand_enemy = longrange_enemy
	
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