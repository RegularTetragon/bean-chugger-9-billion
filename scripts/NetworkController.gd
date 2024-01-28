extends Node
class_name NetworkController
@export var server_prefab : PackedScene
@export var client_prefab : PackedScene
@export var error_dialogue : Panel
@export var client_to_server_remote_prefab : PackedScene


func start_server(port: int):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, 32)
	if err != OK:
		show_error(err)
		return
	var server = server_prefab.instantiate()
	server.name = "Game" + str(port)
	get_tree().set_multiplayer(
		MultiplayerAPI.create_default_interface(),
		NodePath(str(get_path()) + "/Game" + str(port))
	)
	add_child(server)
	server.multiplayer.multiplayer_peer = peer
	server.network = self
	print("Server created")
	
func start_client(address, port):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(address, port)
	if err != OK:
		show_error(err)
		return
	
	var client = client_prefab.instantiate()
	client.name = "Game" + str(port)
	get_tree().set_multiplayer(
		MultiplayerAPI.create_default_interface(),
		NodePath(str(get_path()) + "/Game" + str(port))
	)
	add_child(client)
	client.multiplayer.multiplayer_peer = peer
	client.network = self
	print("Client created")

func show_error(err: int):
	error_dialogue.get_node("VBoxContainer/ErrorLabel").text = error_string(err)
	error_dialogue.visible = true
