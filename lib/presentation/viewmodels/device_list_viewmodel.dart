import 'package:neomano/domain/entities/device.dart';
import 'package:neomano/domain/usecases/connect_device_usecase.dart';
import 'package:neomano/domain/usecases/search_device_usecase.dart';
import 'package:neomano/presentation/viewmodels/viewmodel.dart';

import 'viewmodel.dart';

class DeviceListViewModel extends ViewModel {
  final SearchDeviceUserCase _searchDeviceUserCase;
  final ConnectDeviceUserCase _connectDeviceUserCase;

  List<Device> _foundDevices = [];
  bool _deviceScanning = false;

  get foundDevices => _foundDevices;
  get isDeviceScanning => _deviceScanning;

  DeviceListViewModel(this._searchDeviceUserCase, this._connectDeviceUserCase);

  startScan() async {
    // setBusy();
    _foundDevices.clear();
    _deviceScanning = true;
    notifyListeners();
    await _searchDeviceUserCase.start(SearchDeviceParam(onData: (device) {
      _foundDevices.add(device);
      notifyListeners();
    }));

    // setReady();
  }

  stopScan() {
    _deviceScanning = false;
    notifyListeners();
    _searchDeviceUserCase.start(SearchDeviceParam(stop: true));
    // setReady();
  }

  connectDevice(Device device) async {
    return await _connectDeviceUserCase
        .start(ConnectDeviceParam(device: device));
  }
}
