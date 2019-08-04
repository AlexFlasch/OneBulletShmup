extends Node2D

# node references
onready var deletion_timer = $DeletionTimer
onready var fade_tween = $FadeTween



# Called when the node enters the scene tree for the first time.
func _ready():
	deletion_timer.start()
	fade_tween.interpolate_method(self, 'fade_out', 0.01, 1, 2.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
	fade_tween.start()
# end _ready



func _on_DeletionTimer_timeout():
	queue_free()
# end _on_DeletionTimer_timeout



func fade_out(value):
	self.position.y -= value * 0.5
	self.modulate = Color(1.0, 1.0, 1.0, lerp(1, 0, value))
# end fade_out