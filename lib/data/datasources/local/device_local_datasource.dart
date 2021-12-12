import 'package:neomano/domain/entities/device.dart';

abstract class DeviceLocalDataSource {
  List<Device> getCache();
  bool addCacheIfAbsent(Device device);
  void clearCache();
}

class DeviceLocalDataSourceImpl extends DeviceLocalDataSource {
  List<Device> _cachedDevices = [];

  @override
  List<Device> getCache() {
    return List.unmodifiable(_cachedDevices);
  }

  bool addCacheIfAbsent(Device device) {
    var isDeviceExist = _cachedDevices.any((cachedDevice) {
      if (cachedDevice.identifier == device.identifier) {
        cachedDevice = device;
        return true;
      }
      return false;
    });
    if(!isDeviceExist) {
      _cachedDevices.add(device);
      return true;
    }
    return false;
  }

  void clearCache() {
    _cachedDevices.clear();
  }
}
