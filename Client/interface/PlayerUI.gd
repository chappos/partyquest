extends Control


onready var latency_label = $TopUI/LatencyLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	GameServer.connect("latency_changed", self, "_on_latency_changed")
	
func _on_latency_changed(new_latency):
	latency_label.set_text("Latency: " + str(new_latency))
