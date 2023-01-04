class_name LiveLinkFaceServer, "res://llf_icon.svg"
extends Node

# Thread safe copy of new data
signal data_updated(id, name, data)

export var port: int = 11111
export var use_threads: bool = false

var updated_client_ids: Array = []
var server: LiveLinkFace.Server = null
var server_lock: Mutex = Mutex.new()
var thread: Thread = Thread.new()
var _threads_enabled: bool = false

func _ready():
	server = LiveLinkFace.Server.new(port)
	assert(server.connect("new_client", self, "on_client_connected") == OK)
	assert(server.connect("data_update", self, "on_data_updated") == OK)
	
	_threads_enabled = use_threads
	if _threads_enabled:
		# Launch thread
		if thread.start(self, "poll_thread") != OK:
			push_error("failed to start listener thread for LiveLinkFaceServer")

func _process(_delta):
	if _threads_enabled:
		if(server_lock.try_lock() == OK):
			emit_signals()
			server_lock.unlock()
	else:
		server.poll()
		emit_signals()
	
func emit_signals():
	for id in updated_client_ids:
		var client: LiveLinkFace.Client = server.clients[id]
		emit_signal("data_updated", client.id, client.name, client.values)
	
func poll_thread():
	while true:
		if server_lock.try_lock() == OK:
			server.poll()
			server_lock.unlock()

func on_data_updated(client: LiveLinkFace.Client):
	updated_client_ids.append(client.id)

func on_client_connected(client: LiveLinkFace.Client):
	print("client connected! -> { id: %s, name: %s }" % [client.id, client.name])
