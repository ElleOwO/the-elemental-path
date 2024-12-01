extends Area2D


# gem disappears when Echo picks it up
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Echo":
		queue_free()

# randomly spawns coins
func gem_spawner():
	# loop runs while game is running
	for i in range(4):
		var gem = $GemStoneItem.instanciate()
		$GemStoneItem.add_child(gem)
		gem.position = randi_range(1000, 5000)
