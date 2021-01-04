extends Label

func _on_Timer_timeout():
	self.call_deferred("queue_free")
