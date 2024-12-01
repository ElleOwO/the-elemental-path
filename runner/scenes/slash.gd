extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("Slash")
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_entered", Callable(self, "_on_vine_collided"))
	set_process(true)
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# Detection with vine
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("vine"):
		print("Slash hit vine")
		area.destroy_vine()
		queue_free()
		
func _on_vine_collided(body):
	if body.name == "Echo":  # Ensure it only triggers with the player character
		print("Collision detected with vine")
