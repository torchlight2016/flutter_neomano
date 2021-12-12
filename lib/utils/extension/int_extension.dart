import 'dart:typed_data';

extension IntExtension on int {
  Uint8List convertToByte(int bytesSize,[Endian order = Endian.little]) {
    const kMaxBytes = 8;
    var bytes = Uint8List(kMaxBytes)
      ..buffer.asByteData().setInt64(0, this, order);
    Uint8List uInt8List;
    if (order == Endian.big)
      uInt8List = bytes.sublist(kMaxBytes - bytesSize, kMaxBytes);
    else
      uInt8List = bytes.sublist(0, bytesSize);
    return uInt8List;
  }
}
