extends Camera2D



# node references
onready var shake_tween = $ShakeTween
onready var shake_frequency_timer = $ShakeFrequency
onready var shake_duration_timer = $ShakeDuration



# constants
const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT



# member variables
var amplitude



# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# end _ready

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func shake_screen(duration = 0.2, frequency = 32, amplitude = 16):
	self.amplitude = amplitude
	
	shake_duration_timer.wait_time = duration
	shake_frequency_timer.wait_time = 1 / float(frequency)
	
	shake_duration_timer.start()
	shake_frequency_timer.start()
	
	animate_screen_shake()
# end shake_screen



func animate_screen_shake():
	var rand_vector = Vector2()
	rand_vector.x = rand_range(-amplitude, amplitude)
	rand_vector.y = rand_range(-amplitude, amplitude)
	
	shake_tween.interpolate_property(self, 'offset', self.offset, rand_vector, shake_frequency_timer.wait_time, TRANS, EASE)
	shake_tween.start()
# end shake_screen



func reset():
	shake_tween.interpolate_property(self, 'offset', self.offset, Vector2(0, 0), shake_frequency_timer.wait_time, TRANS, EASE)
	shake_tween.start()



func _on_ShakeFrequency_timeout():
	animate_screen_shake()
# end _on_ShakeTimer_timeout



func _on_ShakeDuration_timeout():
	reset()
# end _on_ShakeDuration_timeout