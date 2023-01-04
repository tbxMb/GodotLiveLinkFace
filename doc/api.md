# API

To use the server just add the `LiveLinkFaceServer` node to your node tree just like any other node.
Then connect the `data_updated` signal to your code. The signal recieves three parameters
1. `id` this is the unieque device id
2. `name` this is the device name  
3. `data` blendshape data

The data argument is of type `LiveLinkFace.ClientData` this data structure contains getters for all 61 blendshapes 
this means you can acces them without issue like this `data.head_pitch`.

**Note: Do not use threading the performance using threading is terrible!**

If you want to see a practical example of this check out the `example` folder.
If you instead of the `LiveLinkFaceServer` node you want to use the `LiveLinkFace.Server` class you can look at the `LiveLinkFaceServer` implementation in `live_link/server.gd` or look at the addon in `addons/live_link_face_tool`.

## Utility
In `live_link/face_link.gd` there is a map of all blend_shape names, it maps the index of each blendshape 
value to a string that you can use to set the blendshapes on a mesh, you can access it via `LiveLinkFace.KEYMAP`.