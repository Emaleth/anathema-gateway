extends Node

var network := ENetMultiplayerPeer.new()
var gateway_api := MultiplayerAPI.create_default_interface()
var port := 1910
var max_players := 100


func _ready() -> void:
	StartServer()

func _process(_delta: float) -> void:
	if gateway_api.has_multiplayer_peer():
		gateway_api.poll()


func StartServer() -> void:
	network.create_server(port, max_players)
	get_tree().set_multiplayer(gateway_api, self.get_path())
	gateway_api.multiplayer_peer = network
	print("Gateway Server started")

	gateway_api.peer_connected.connect(_Peer_Connected)
	gateway_api.peer_disconnected.connect(_Peer_Disconnected)


func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")


func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
