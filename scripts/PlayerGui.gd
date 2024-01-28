extends Control

var paused = false
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Health.text = str(get_parent().character.health) if is_instance_valid(get_parent().character) else "Respawning..."
	if Input.is_action_just_pressed("pause"):
		paused = !paused
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED
		$Paused.visible = paused

func quit():
	get_parent().client.multiplayer.multiplayer_peer = null
	get_parent().client.queue_free()
