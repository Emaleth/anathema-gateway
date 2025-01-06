extends Node

var network := ENetMultiplayerPeer.new()
var ip := "127.0.0.1"
var port := 1911


func _ready() -> void:
	ConnectToServer()


func ConnectToServer():
	network.create_client(ip, port)
	multiplayer.multiplayer_peer = network

	multiplayer.connection_failed.connect(_OnConnectionFailed)
	multiplayer.connected_to_server.connect(_OnConnectionSucceeded)
	multiplayer.server_disconnected.connect(_OnDisconnection)

func _OnConnectionFailed():
	print("Failed to connect to the authentication server")


func _OnConnectionSucceeded():
	print("Succesfully connected to the authentication server")


func _OnDisconnection():
	print("Succesfully disconnected from the authentication server")
