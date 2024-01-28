extends Node
class_name NetworkClient

@export var local_player : PackedScene
@export var remote_player : PackedScene
@export var projectile_prefab : PackedScene

var network : NetworkController
var current_level : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.connection_failed.connect(server_disconnected)
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	print("Ready")
func connected_to_server():
	print("Client connected to server")
	var player = local_player.instantiate()
	player.name = "Player" + str(multiplayer.get_unique_id())
	player.client = self
	player.peer_id = multiplayer.get_unique_id()
	$Players.add_child(player)

func server_disconnected():
	print("Client disconnected from server")
	queue_free()
	network.show_error(ERR_CANT_CONNECT)
	
func connection_failed():
	print("Can't connect")
	queue_free()
	network.show_error(ERR_CANT_CONNECT)

func peer_connected(id):
	if id != 1:
		var player = remote_player.instantiate()
		player.client = self
		player.peer_id = id
		player.name = "Player" + str(id)
		$Players.add_child(player)

func peer_disconnected(id):
	if id != 1:
		var player = $Players.get_node("Player" + str(id))
		player.queue_free()


@rpc("reliable", "authority")
func set_map(map_name: String):
	if current_level:
		current_level.queue_free()
	var map = load("res://maps/" + map_name + ".tscn").instantiate()
	$World.add_child(map)
	current_level = map

@rpc("reliable", "authority")
func s2c_sync_player(id):
	peer_connected(id)

@rpc("reliable", "authority")
func s2c_sync_projectile(id, position, velocity):
	var bean = projectile_prefab.instantiate()
	bean.name = "Projectile" + str(id)
	$World/Projectiles.add_child(bean)
	bean.global_position = position
	bean.linear_velocity = velocity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
