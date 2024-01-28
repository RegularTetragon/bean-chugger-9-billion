extends Node
class_name NetworkServer
var network : NetworkController 
@export var server_player : PackedScene
@export var projectile_prefab : PackedScene
var current_level : Node3D
var current_level_name : String
var projectiles : ProjectileSyncServer

# Called when the node enters the scene tree for the first time.
func _ready():
	projectiles = $World/Projectiles
	print("Server ready")
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	set_map("test")

func peer_connected(id):
	print("Server connected to client")
	var client = server_player.instantiate()
	client.server = self
	client.name = "Player" + str(id)
	client.peer_id = id
	# sync existing stuff with the player who joined
	for player : PlayerServer in $Players.get_children():
		s2c_sync_player(player.peer_id)
		if is_instance_valid(player.character):
			player.spawn_character.rpc_id(id, player.character.global_position)
	
	$Players.add_child(client)
	set_map.rpc_id(id, current_level_name)

func peer_disconnected(id):
	print("Server disconnected from peer")
	var player : PlayerServer = $Players.get_node("Player" + str(id))
	player.character.queue_free()
	player.queue_free()

@rpc("authority", "reliable")
func set_map(map_name: String):
	if current_level:
		current_level.queue_free()
	var map = load("res://maps/" + map_name + ".tscn").instantiate()
	$World.add_child(map)
	current_level = map
	current_level_name = map_name
	set_map.rpc(map_name)

@rpc("reliable", "authority")
func s2c_sync_player(id):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
