extends Spatial

onready var mesh: MeshInstance = $Armature/Skeleton/Chicken

func _on_LiveLinkFaceServer_data_updated(_id: String, _name: String, data: LiveLinkFace.ClientData):
	for i in range(data.data.size()):
		var value = data.data[i]
		mesh.set(LiveLinkFace.KEY_MAP[i], value)
