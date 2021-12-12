import 'package:neomano/domain/entities/device.dart';
import 'package:neomano/domain/usecases/control_device_usecase.dart';

abstract class DeviceRepository {
  void startScan(void onData(Device device));
  void stopScan();
  Future<bool> connectDevice(Device device);
  Future<void> disconnectDevice();
  Future<void> controlDevice(ControlDeviceParam param);
}