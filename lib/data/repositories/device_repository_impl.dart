import 'package:neomano/data/datasources/device/device_datasource.dart';
import 'package:neomano/data/datasources/local/device_local_datasource.dart';
import 'package:neomano/domain/entities/device.dart';
import 'package:neomano/domain/repositories/device_repository.dart';
import 'package:neomano/domain/usecases/control_device_usecase.dart';

class DeviceRepositoryImpl extends DeviceRepository {
  final DeviceDataSource _deviceSource;
  final DeviceLocalDataSource _deviceLocalDataSource;

  DeviceRepositoryImpl(this._deviceSource, this._deviceLocalDataSource);

  @override
  Future<void> startScan(void onData(Device device)) async {
    _deviceLocalDataSource.clearCache();
    // DateTime scanStartTime = DateTime.now();
    await _deviceSource.startScan((device) {
      if(device.name.startsWith('NM')) {
        if(_deviceLocalDataSource.addCacheIfAbsent(device)){
          onData(device);
        }
      }
    });
    // return _deviceLocalDataSource.getCache();
  }

  @override
  Future<void> stopScan() async {
    await _deviceSource.stopScan();
  }

  @override
  Future<bool> connectDevice(Device device) async {
    var connected = await _deviceSource.connectDevice(device);
    return connected;
  }

  @override
  Future<void> controlDevice(ControlDeviceParam param) async {
    await _deviceSource.controlDevice(param);
  }

  @override
  Future<void> disconnectDevice() async {
    await _deviceSource.disconnectDevice();
  }
}