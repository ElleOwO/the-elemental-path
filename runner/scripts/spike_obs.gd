extends StaticBody2D

@onready var hitbox: Area2D = $SpikeHitbox
@onready var hitbox2: Area2D = $SpikeHitbox2

signal game_over_triggered

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Spikes_obs")
	
	#Add fire obstacle to fire group since this will react differently than the others
	hitbox.connect("area_entered", Callable(self, "_on_spikeobs_hitbox_area_entered"))
	hitbox2.connect("area_entered", Callable(self, "_on_spikeobs_hitbox_area_entered"))
	
	hitbox.connect("body_entered", Callable(self, "_on_spikeobs_hitbox_area_entered"))
	hitbox2.connect("body_entered", Callable(self, "_on_spike_hitbox_2_body_entered"))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_spikeobs_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().game_over()
		print("Spikes collided with player")
	


func _on_spike_hitbox_2_body_entered(body: Node2D) -> void:
	if body.name == "Echo":
		print("Echo landed in spikes")
		emit_signal("game_over_triggered")


func _on_spike_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Echo":
		print("Echo landed in spikes")
		emit_signal("game_over_triggered")
