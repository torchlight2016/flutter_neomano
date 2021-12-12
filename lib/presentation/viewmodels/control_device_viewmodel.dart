import 'package:neomano/domain/usecases/connect_device_usecase.dart';
import 'package:neomano/domain/usecases/control_device_usecase.dart';

class ControlDeviceViewModel {
  final ControlDeviceUseCase _controlDeviceUseCase;
  final ConnectDeviceUserCase _connectDeviceUserCase;

  ControlDeviceViewModel(
      this._controlDeviceUseCase, this._connectDeviceUserCase);

  controlDevice(ControlDeviceParam param) async {
    await _controlDeviceUseCase.start(param);
  }

  disconnectDevice() async {
    return await _connectDeviceUserCase
        .start(ConnectDeviceParam(disconnect: true));
  }
}
