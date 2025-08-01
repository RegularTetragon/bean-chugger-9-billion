extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	last_mouse_position = get_viewport().get_mouse_position()
	pass # Replace with function body.

var last_mouse_position
var xrot = 0
var yrot = 0

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_diff = event.relative / 100
		xrot -= mouse_diff.x
		yrot -= mouse_diff.y
		yrot = clamp(yrot, -PI/2, PI/2)
		rotation = Vector3(yrot, xrot, 0)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(Vector3(
		Input.get_axis("walk_left", "walk_right"), 
		0,
		Input.get_axis("walk_forward", "walk_backwards"),
	) * 32 * delta)
	var new_mouse_position = get_viewport().get_mouse_position()
	var delta_mouse = (new_mouse_position - last_mouse_position)
	xrot += -delta_mouse.y * delta / 10
	yrot += -delta_mouse.x * delta / 10
	
	last_mouse_position = new_mouse_position
	
