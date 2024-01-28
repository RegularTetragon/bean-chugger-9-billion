extends Panel
@export var controller : NetworkController

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Start.pressed.connect(start_server)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func start_server():
	controller.start_server(
		int($VBoxContainer/GridContainer/Address.text)
	)
	visible = false
