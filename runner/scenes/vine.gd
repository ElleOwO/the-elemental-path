extends StaticBody2D

@onready var hitbox: Area2D = $Vine_hitbox

var is_destroyed : bool = false
signal vine_collided

# Called when the node enters the scene tree for the first time.
func _ready():
	hitbox.connect("area_entered", Callable(self, "_on_vine_hitbox_area_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func destroy_vine():
	if not is_destroyed:
		is_destroyed = true
		#Remove Vine from scene
		queue_free()
		print("Vine Destroyed!")


func _on_vine_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Fire_Attack"):
		queue_free()
		print("Vine Destroyed!")
	else:
		print("Cannot use this power")
	
