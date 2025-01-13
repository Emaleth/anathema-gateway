extends Node

var network := ENetMultiplayerPeer.new()
var gateway_api := MultiplayerAPI.create_default_interface()
var port := 1910
var max_players := 100
var cert = load("res://X509_Certificate.crt")
var key = load("res://X509_Key.key")

func _ready() -> void:
	StartServer()

func _process(_delta: float) -> void:
	if not gateway_api.has_multiplayer_peer():
		return
	gateway_api.poll()


func StartServer() -> void:
	network.create_server(port, max_players)
	network.host.dtls_server_setup(TLSOptions.server(key, cert))
	get_tree().set_multiplayer(gateway_api, self.get_path())
	gateway_api.multiplayer_peer = network
	print("Gateway Server started")

	gateway_api.peer_connected.connect(_Peer_Connected)
	gateway_api.peer_disconnected.connect(_Peer_Disconnected)


func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")


func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")

@rpc("any_peer", "reliable")
func client_to_gateway_login(_username, _password):
	var player_id := gateway_api.get_remote_sender_id()
	Authenticator.gateway_to_authenticator_authenticate_player(player_id, _username, _password)

@rpc("any_peer", "reliable")
func client_to_gateway_create_account(_username : String, _password : String):
	var player_id := gateway_api.get_remote_sender_id()
	var valid_request = true
	if _username == "":
		valid_request = false
	if _password == "":
		valid_request = false
	if _password.length() < 8:
		valid_request = false
	if valid_request == false:
		gateway_to_client_create_account(valid_request, player_id, 1)
	else:
		Authenticator.gateway_to_authenticator_create_account(_username.to_lower(), _password, player_id)

@rpc("reliable")
func gateway_to_client_login_result(result, player_id, token):
	gateway_api.rpc(player_id, self, "gateway_to_client_login_result", [result, token])
	network.get_peer(player_id).peer_disconnect_later()

@rpc("reliable")
func gateway_to_client_create_account(result, player_id, message):
	gateway_api.rpc(player_id, self, "gateway_to_client_create_account", [result, message])
	network.get_peer(player_id).peer_disconnect_later()
