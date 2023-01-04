#ifndef __FACELINK_PROTO_H
#define __FACELINK_PROTO_H

struct PacketHeader {
    uint8_t __magic_1;
    uint32_t device_id_length;
    char *device_id;
    uint32_t device_name_length;
    char *device_name;
    uint64_t time_stamp;
    uint8_t __magic_2[8];
};

struct FacePacket {
  PacketHeader header;
  uint8_t blend_shape_count;
  f32_t *blend_shapes;
}

#endif
