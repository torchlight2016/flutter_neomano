import 'package:neomano/domain/entities/device.dart';
import 'package:neomano/domain/repositories/device_repository.dart';
import 'package:neomano/domain/usecases/usecase.dart';

class ConnectDeviceUserCase extends UseCase<bool,ConnectDeviceParam>{
  final DeviceRepository _deviceRepository;

  ConnectDeviceUserCase(this._deviceRepository);

  @override
  Future<bool> start([ConnectDeviceParam param]) async{
    if(param.disconnect == true){
      await _deviceRepository.disconnectDevice();
      return await Future.value(true);
    }
    return await _deviceRepository.connectDevice(param.device);
  }
}

class ConnectDeviceParam {
  final Device device;
  final disconnect;

  ConnectDeviceParam({this.device, this.disconnect});
}