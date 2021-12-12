import 'package:neomano/domain/repositories/device_repository.dart';
import 'package:neomano/domain/usecases/usecase.dart';

class ControlDeviceUseCase extends UseCase<void,ControlDeviceParam> {
  final DeviceRepository _deviceRepository;

  ControlDeviceUseCase(this._deviceRepository);

  @override
  Future<void> start([ControlDeviceParam param]) async{
    await _deviceRepository.controlDevice(param);
  }

}

enum DeviceAction{
  start,
  stop,
}

enum DeviceDirection{
  grip,
  release,
}

class ControlDeviceParam{
  final DeviceAction action;
  final DeviceDirection direction;
  final int speed;

  ControlDeviceParam(this.action, {this.direction, this.speed});
}