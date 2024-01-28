extends Node
class_name PlayerRemote

@export var remote_character_prefab : PackedScene
var character : Node3D
var peer_id : int
var client : NetworkClient

@rpc("authority", "reliable")
func spawn_character(position):
	character = remote_character_prefab.instantiate()
	character.position = position
	character.name = "Character" + str(peer_id)
	client.get_node("World").add_child(character)

