extends StaticBody2D

@onready var hitbox: Area2D = $Vine_hitbox

# Called when the node enters the scene tree for the first time.
func _ready():
	#Connect the hitbox for vine
	hitbox.connect("area_entered", Callable(self, "_on_vine_hitbox_area_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_vine_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Fire_Attack"):
		#Removes vine, main.gd spawns another when prompted
		queue_free()
		print("Vine Destroyed!")
	else:
		print("Cannot use this power")
	
