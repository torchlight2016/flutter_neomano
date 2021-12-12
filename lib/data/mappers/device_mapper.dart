import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:neomano/domain/entities/device.dart';

class DeviceMapper {
  static Device mapperToDevice(ScanResult scanResult) {
    return Device(scanResult.peripheral.name, scanResult.peripheral.identifier,
        scanResult.advertisementData?.serviceUuids?.first ?? null,scanResult.peripheral);
  }
}
