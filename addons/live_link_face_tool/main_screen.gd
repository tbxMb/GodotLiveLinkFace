tool
extends Control

const ITEM_FORMAT = "%s: %s"
const active_color = Color(0.5, 1, 0)
const inactive_color = Color(1, 0.506592, 0.265625)

onready var face: MeshInstance = $"%face"
onready var face_material: SpatialMaterial = face.get_surface_material(0) as SpatialMaterial
onready var client_list: ItemList = $"%ClientList"
onready var port_field: SpinBox = $"%PortField"
onready var checkbox: CheckBox = $"%ServerState"

var server_active: bool = false
var server: LiveLinkFace.Server = null
var sel: String = ""

func _ready():
	server = LiveLinkFace.Server.new(port_field.value)
	server.connect("new_client", self, "_on_server_new_client")
	server.connect("data_update", self, "_on_server_data_update")
	server.connect("client_removed", self, "_on_server_client_removed")
	change_color(inactive_color)

func _process(_delta):
	if server_active:
		server.poll()

func change_color(new_color: Color):
	create_tween().tween_property(face_material, "albedo_color", new_color, 1.0)

func change_server_state(state: bool):
	server_active = state
	
	if server_active:
		change_color(active_color)
		server.port = port_field.value
		server.listen()
	else:
		change_color(inactive_color)
		server.stop()


func update_mesh(data: LiveLinkFace.ClientData):
	var rotation = Vector3( - data.head_pitch, data.head_yaw, data.head_roll ) * 0.1
	
	for i in range(data.data.size()):
		var value = data.data[i]
		face.set(LiveLinkFace.KEY_MAP[i], value)

func _on_CheckBox_toggled(button_pressed):
	port_field.editable = !button_pressed
	change_server_state(button_pressed)

func _on_Control_visibility_changed():
	change_server_state(visible and checkbox.pressed)

func _on_server_new_client(client: LiveLinkFace.Client):
	client_list.add_item(ITEM_FORMAT % [client.name, client.id], null, true)
	
	if client_list.get_item_count() == 1:
		sel = ITEM_FORMAT % [client.name, client.id]
		client_list.select(0)
	
func _on_server_data_update(client: LiveLinkFace.Client):
	if sel == (ITEM_FORMAT % [client.name, client.id]):
		update_mesh(client.values)
	
func _on_server_client_removed(client: LiveLinkFace.Client):
	client_list.clear()

func _on_ClientList_item_selected(index):
	sel = client_list.get_item_text(index)
