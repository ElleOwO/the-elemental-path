extends Node2D

@onready var middle_hitbox: Area2D = $Middle/Middle_Rock_hitbox
#@onready var top_hitbox: Area2D = $"Top and Bottom/T_and_B_Sprites/Top_pillar"
#@onready var bottom_hitbox: Area2D = $"Top and Bottom/T_and_B_Sprites/Bottom_pillar"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	middle_hitbox.connect("area_entered", Callable(self, "_on_middle_rock_hitbox_area_entered"))
	#top_hitbox.connect("area_entered", Callable(self, "_on_top_pillar_area_entered"))
	#bottom_hitbox.connect("area_entered", Callable(self, "_on_bottom_pillar_area_entered"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_middle_rock_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Earth_push"):
		queue_free()
		print("Rock Destroyed!")
	else:
		print("Cannot use this power")


func _on_top_pillar_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_bottom_pillar_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
