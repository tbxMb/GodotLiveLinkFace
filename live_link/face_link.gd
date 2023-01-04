class_name LiveLinkFace

class Server:
	signal new_client(client)
	signal data_update(client)
	signal client_removed(client)
	
	var server: UDPServer
	var port: int
	
	var clients := {}
	var _unidentified_peers := []
	
	func _init(_port: int):
		port = _port
		server = UDPServer.new()
		var err = server.listen(port)
		if err != OK:
			push_error("failed to listen on port %d" % port)
	
	func stop():
		server.stop()
		
		for client in clients:
			emit_signal("client_removed", client)
			
		clients.clear()
		_unidentified_peers.clear()
		
	func listen():
		var err = server.listen(port)
		if err != OK:
			push_error("failed to listen on port %d" % port)
	
	func poll():
		print_stack()
		
		if server.poll() != OK:
			push_error("failed to poll UDPServer")
		
		if server.is_connection_available():
			var peer = server.take_connection()
			
			if peer != null:
				_unidentified_peers.append(peer)

			# TODO: Maybe error
		
		var resolved_peers := []
		for i in range(_unidentified_peers.size()):
			var peer: PacketPeerUDP = _unidentified_peers[i]
			var packet_count = peer.get_available_packet_count()
			
			if packet_count == 0:
				break
			
			for _i in range(packet_count-1):
				var _p = peer.get_packet()
			
			# Parse packet and identify peer
			var packet: Packet = Packet.from_bytes(peer.get_packet())
			
			if clients.has(packet.device_id):
				# Close and replace connection
				var client: Client = clients[packet.device_id]
				client._connection.close()
				client._connection = peer
				clients[packet.device_id] = client
			
			else:
				# Create client
				var client: Client = Client.new()
				client._connection = peer
				client._last_seen = packet.time_stamp
				client.id = packet.device_id
				client.name = packet.device_name
				
				if packet.blend_shapes.size() == 61:
					client.values = ClientData.new(packet)
				
				clients[packet.device_id] = client;
				
				# Emit signal new_client
				emit_signal("new_client", client)
		
			resolved_peers.append(i)
		
		# Clear _unidentified_peers
		if _unidentified_peers.size() > 0:
			var tmp_unidentified := []
			for i in range(_unidentified_peers.size()):
				if resolved_peers.find(i) == -1:
					tmp_unidentified.append(_unidentified_peers[i])
			
			_unidentified_peers = tmp_unidentified
		
		# Poll packets from already connected clients 
		for id in clients:
			var client: Client = clients[id]
			var packets_available = client._connection.get_available_packet_count()
			
			if packets_available == 0:
				continue
			
			for _i in range(packets_available-1):
				var _p = client._connection.get_packet()
			
			var packet: Packet = Packet.from_bytes(client._connection.get_packet())
			
			client._last_seen = packet.time_stamp
			
			if packet.blend_shapes.size() == 61:
				client.values = ClientData.new(packet)
				
				emit_signal("data_update", client)
			

class Packet:
	var __magic_1
	var device_id: String
	var device_name: String
	var time_stamp: int
	var __magic_2
	
	var blend_shapes: PoolRealArray
	
	static func from_bytes(data) -> Packet:
		var stream = StreamPeerBuffer.new()
		stream.data_array = data
		stream.big_endian = true
		
		var obj = Packet.new()
		
		obj.__magic_1 = stream.get_u8()
		obj.device_id = stream.get_string()
		obj.device_name = stream.get_string()
		obj.time_stamp = stream.get_u64()
		obj.__magic_2 = stream.get_u64()
		
		if stream.get_size() - stream.get_position() > 0:
			var blend_shape_count = stream.get_u8()
			var _blend_shapes = []
			
			for _i in range(0, blend_shape_count):
				_blend_shapes.append(stream.get_float())
			
			obj.blend_shapes = PoolRealArray(_blend_shapes)
		
		return obj

class Client:
	var id: String
	var name: String
	
	var _last_seen: int
	var _connection: PacketPeerUDP
	var values: ClientData

class ClientData:	
	var timecode: int 
	var data: PoolRealArray
	
	func _init(packet: Packet):
		timecode = packet.time_stamp
		data = packet.blend_shapes

	var blend_shape_count setget ,_get_blend_shape_count
	var eye_blink_left setget ,_get_eye_blink_left
	var eye_look_down_left setget ,_get_eye_look_down_left
	var eye_look_in_left setget ,_get_eye_look_in_left
	var eye_look_out_left setget ,_get_eye_look_out_left
	var eye_look_up_left setget ,_get_eye_look_up_left
	var eye_squint_left setget ,_get_eye_squint_left
	var eye_wide_left setget ,_get_eye_wide_left
	var eye_blink_right setget ,_get_eye_blink_right
	var eye_look_down_right setget ,_get_eye_look_down_right
	var eye_look_in_right setget ,_get_eye_look_in_right
	var eye_look_out_right setget ,_get_eye_look_out_right
	var eye_look_up_right setget ,_get_eye_look_up_right
	var eye_squint_right setget ,_get_eye_squint_right
	var eye_wide_right setget ,_get_eye_wide_right
	var jaw_forward setget ,_get_jaw_forward
	var jaw_right setget ,_get_jaw_right
	var jaw_left setget ,_get_jaw_left
	var jaw_open setget ,_get_jaw_open
	var mouth_close setget ,_get_mouth_close
	var mouth_funnel setget ,_get_mouth_funnel
	var mouth_pucker setget ,_get_mouth_pucker
	var mouth_right setget ,_get_mouth_right
	var mouth_left setget ,_get_mouth_left
	var mouth_smile_left setget ,_get_mouth_smile_left
	var mouth_smile_right setget ,_get_mouth_smile_right
	var mouth_frown_left setget ,_get_mouth_frown_left
	var mouth_frown_right setget ,_get_mouth_frown_right
	var mouth_dimple_left setget ,_get_mouth_dimple_left
	var mouth_dimple_right setget ,_get_mouth_dimple_right
	var mouth_stretch_left setget ,_get_mouth_stretch_left
	var mouth_stretch_right setget ,_get_mouth_stretch_right
	var mouth_roll_lower setget ,_get_mouth_roll_lower
	var mouth_roll_upper setget ,_get_mouth_roll_upper
	var mouth_shrug_lower setget ,_get_mouth_shrug_lower
	var mouth_shrug_upper setget ,_get_mouth_shrug_upper
	var mouth_press_left setget ,_get_mouth_press_left
	var mouth_press_right setget ,_get_mouth_press_right
	var mouth_lower_down_left setget ,_get_mouth_lower_down_left
	var mouth_lower_down_right setget ,_get_mouth_lower_down_right
	var mouth_upper_up_left setget ,_get_mouth_upper_up_left
	var mouth_upper_up_right setget ,_get_mouth_upper_up_right
	var brow_down_left setget ,_get_brow_down_left
	var brow_down_right setget ,_get_brow_down_right
	var brow_inner_up setget ,_get_brow_inner_up
	var brow_outer_up_left setget ,_get_brow_outer_up_left
	var brow_outer_up_right setget ,_get_brow_outer_up_right
	var cheek_puff setget ,_get_cheek_puff
	var cheek_squint_left setget ,_get_cheek_squint_left
	var cheek_squint_right setget ,_get_cheek_squint_right
	var nose_sneer_left setget ,_get_nose_sneer_left
	var nose_sneer_right setget ,_get_nose_sneer_right
	var tongue_out setget ,_get_tongue_out
	var head_yaw setget ,_get_head_yaw
	var head_pitch setget ,_get_head_pitch
	var head_roll setget ,_get_head_roll
	var left_eye_yaw setget ,_get_left_eye_yaw
	var left_eye_pitch setget ,_get_left_eye_pitch
	var left_eye_roll setget ,_get_left_eye_roll
	var right_eye_yaw setget ,_get_right_eye_yaw
	var right_eye_pitch setget ,_get_right_eye_pitch
	var right_eye_roll setget ,_get_right_eye_roll

	func _get_blend_shape_count():
		return data[0]

	func _get_eye_blink_left():
		return data[1]

	func _get_eye_look_down_left():
		return data[2]

	func _get_eye_look_in_left():
		return data[3]

	func _get_eye_look_out_left():
		return data[4]

	func _get_eye_look_up_left():
		return data[5]

	func _get_eye_squint_left():
		return data[6]

	func _get_eye_wide_left():
		return data[7]

	func _get_eye_blink_right():
		return data[8]

	func _get_eye_look_down_right():
		return data[9]

	func _get_eye_look_in_right():
		return data[10]

	func _get_eye_look_out_right():
		return data[11]

	func _get_eye_look_up_right():
		return data[12]

	func _get_eye_squint_right():
		return data[13]

	func _get_eye_wide_right():
		return data[14]

	func _get_jaw_forward():
		return data[15]

	func _get_jaw_right():
		return data[16]

	func _get_jaw_left():
		return data[17]

	func _get_jaw_open():
		return data[18]

	func _get_mouth_close():
		return data[19]

	func _get_mouth_funnel():
		return data[20]

	func _get_mouth_pucker():
		return data[21]

	func _get_mouth_right():
		return data[22]

	func _get_mouth_left():
		return data[23]

	func _get_mouth_smile_left():
		return data[24]

	func _get_mouth_smile_right():
		return data[25]

	func _get_mouth_frown_left():
		return data[26]

	func _get_mouth_frown_right():
		return data[27]

	func _get_mouth_dimple_left():
		return data[28]

	func _get_mouth_dimple_right():
		return data[29]

	func _get_mouth_stretch_left():
		return data[30]

	func _get_mouth_stretch_right():
		return data[31]

	func _get_mouth_roll_lower():
		return data[32]

	func _get_mouth_roll_upper():
		return data[33]

	func _get_mouth_shrug_lower():
		return data[34]

	func _get_mouth_shrug_upper():
		return data[35]

	func _get_mouth_press_left():
		return data[36]

	func _get_mouth_press_right():
		return data[37]

	func _get_mouth_lower_down_left():
		return data[38]

	func _get_mouth_lower_down_right():
		return data[39]

	func _get_mouth_upper_up_left():
		return data[40]

	func _get_mouth_upper_up_right():
		return data[41]

	func _get_brow_down_left():
		return data[42]

	func _get_brow_down_right():
		return data[43]

	func _get_brow_inner_up():
		return data[44]

	func _get_brow_outer_up_left():
		return data[45]

	func _get_brow_outer_up_right():
		return data[46]

	func _get_cheek_puff():
		return data[47]

	func _get_cheek_squint_left():
		return data[48]

	func _get_cheek_squint_right():
		return data[49]

	func _get_nose_sneer_left():
		return data[50]

	func _get_nose_sneer_right():
		return data[51]

	func _get_tongue_out():
		return data[52]

	func _get_head_yaw():
		return data[53]

	func _get_head_pitch():
		return data[54]

	func _get_head_roll():
		return data[55]

	func _get_left_eye_yaw():
		return data[56]

	func _get_left_eye_pitch():
		return data[57]

	func _get_left_eye_roll():
		return data[58]

	func _get_right_eye_yaw():
		return data[59]

	func _get_right_eye_pitch():
		return data[60]

	func _get_right_eye_roll():
		return data[61]

const KEY_MAP = [
	"blend_shapes/eyeBlinkLeft",
	"blend_shapes/eyeLookDownLeft",
	"blend_shapes/eyeLookInLeft",
	"blend_shapes/eyeLookOutLeft",
	"blend_shapes/eyeLookUpLeft",
	"blend_shapes/eyeSquintLeft",
	"blend_shapes/eyeWideLeft",
	"blend_shapes/eyeBlinkRight",
	"blend_shapes/eyeLookDownRight",
	"blend_shapes/eyeLookInRight",
	"blend_shapes/eyeLookOutRight",
	"blend_shapes/eyeLookUpRight",
	"blend_shapes/eyeSquintRight",
	"blend_shapes/eyeWideRight",
	"blend_shapes/jawForward",
	"blend_shapes/jawRight",
	"blend_shapes/jawLeft",
	"blend_shapes/jawOpen",
	"blend_shapes/mouthClose",
	"blend_shapes/mouthFunnel",
	"blend_shapes/mouthPucker",
	"blend_shapes/mouthRight",
	"blend_shapes/mouthLeft",
	"blend_shapes/mouthSmileLeft",
	"blend_shapes/mouthSmileRight",
	"blend_shapes/mouthFrownLeft",
	"blend_shapes/mouthFrownRight",
	"blend_shapes/mouthDimpleLeft",
	"blend_shapes/mouthDimpleRight",
	"blend_shapes/mouthStretchLeft",
	"blend_shapes/mouthStretchRight",
	"blend_shapes/mouthRollLower",
	"blend_shapes/mouthRollUpper",
	"blend_shapes/mouthShrugLower",
	"blend_shapes/mouthShrugUpper",
	"blend_shapes/mouthPressLeft",
	"blend_shapes/mouthPressRight",
	"blend_shapes/mouthLowerDownLeft",
	"blend_shapes/mouthLowerDownRight",
	"blend_shapes/mouthUpperUpLeft",
	"blend_shapes/mouthUpperUpRight",
	"blend_shapes/browDownLeft",
	"blend_shapes/browDownRight",
	"blend_shapes/browInnerUp",
	"blend_shapes/browOuterUpLeft",
	"blend_shapes/browOuterUpRight",
	"blend_shapes/cheekPuff",
	"blend_shapes/cheekSquintLeft",
	"blend_shapes/cheekSquintRight",
	"blend_shapes/noseSneerLeft",
	"blend_shapes/noseSneerRight",
	"blend_shapes/tongueOut",
	"blend_shapes/headYaw",
	"blend_shapes/headPitch",
	"blend_shapes/headRoll",
	"blend_shapes/leftEyeYaw",
	"blend_shapes/leftEyePitch",
	"blend_shapes/leftEyeRoll",
	"blend_shapes/rightEyeYaw",
	"blend_shapes/rightEyePitch",
	"blend_shapes/rightEyeRoll"
]
