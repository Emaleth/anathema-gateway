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

@rpc("reliable")
func gateway_to_authenticator_authenticate_player(player_id, _username, _password):
	multiplayer.rpc(1, self, "gateway_to_authenticator_authenticate_player", [player_id, _username, _password])

@rpc("reliable")
func authenticator_to_gateway_authenticate_player(_result, _player_id, token):
	print("forwarding login results to the player")
	Gateway.gateway_to_client_login_result(_result, _player_id, token)

@rpc("reliable")
func gateway_to_authenticator_create_account(_username, _password, player_id):
	pass
