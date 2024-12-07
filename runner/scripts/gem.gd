extends Area2D
class_name Gem

@onready var gem_sound = $GemSound

func _ready():
	# Connect the area’s body_entered signal here
	connect("body_entered", Callable(self, "_on_body_entered"))



func _on_area_entered(area: Area2D) -> void:
	gem_sound.stop()
	if area.name == "Echo":
		gem_sound.play()
		
		queue_free()
		print("gem picked up")
	else:
		gem_sound.stop()
	queue_free()
