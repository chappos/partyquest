extends Area2D

var is_grounded = false

func on_parent_jumped():
	self.monitoring = false
	is_grounded = false
	$JumpTimer.start(0.1)

func _on_GroundCheck_body_entered(_body):
	is_grounded = true


func _on_GroundCheck_body_exited(_body):
	is_grounded = false

func _on_JumpTimer_timeout():
	self.monitoring = true
