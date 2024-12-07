extends HBoxContainer
@onready var s : TextureButton = $SPACE #air
@onready var a : TextureButton = $A #rock
@onready var d : TextureButton = $D #fire
@onready var w : TextureButton = $W #water
@onready var h : HBoxContainer = $HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("air"):
		s.modulate = Color(0.2, 0.2, 0.2)
	elif Input.is_action_just_released("air"):
		s.modulate = Color(1,1,1)
	if Input.is_action_just_pressed("water"):
		w.modulate = Color(0.2, 0.2, 0.2)
	elif Input.is_action_just_released("water"):
		w.modulate = Color(1,1,1)
	if Input.is_action_just_pressed("fire"):
		d.modulate = Color(0.2, 0.2, 0.2)
	elif Input.is_action_just_released("fire"):
		d.modulate = Color(1,1,1)
	if Input.is_action_just_pressed("earth"):
		a.modulate = Color(0.2, 0.2, 0.2)	
	elif Input.is_action_just_released("earth"):
		a.modulate = Color(1,1,1)
