# LiveLinkFace - Protocol

The protocol used by the Live Link Face app is quite simple it only contains a header and up to 61 blendshape values.

The structure of the packet looks something like this.

```rust
struct Packet {
    magic_1: u8,
    id_length: u32,
    id: str,
    name_length: u32,
    name: str,
    timestamp: u64
    magic_2: u64
    blendshapes: Option<[f32; 61]>
}
```

The header of the packet contains a device id, the name of the device and a timestamp.
This data is continiously sent to the server the blendshape values on the other hand are only sent
when a face is present in the frame.  

The device `name` can be altered inside of the app settings while the `id` seems to be unique per device and cannot be changed.
The first magic value `magic_1` seems to be the version of the protocol (at the moment of writing this there are two major versions),
the second one `magic_2` might be part of the time code but this is yet to be figured out.

With the timecode im still not sure what to do with it, for the moment it can be used to compare two packets but im still working on 
translating it to some useful date/time.