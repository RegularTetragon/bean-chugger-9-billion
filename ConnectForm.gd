extends Panel
@export var controller : NetworkController

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Connect.pressed.connect(start_server)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func start_server():
	controller.start_client(
		$VBoxContainer/GridContainer/Address.text,
		int($VBoxContainer/GridContainer/Port.text)
	)
	visible = false
