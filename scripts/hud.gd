extends CanvasLayer


@onready var gem_label = $GemLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func update_gem_count(gem_count: int) -> void:
	gem_label.text = "GEMS: " + str(gem_count)
