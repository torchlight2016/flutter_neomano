import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:neomano/domain/entities/device.dart';
import 'package:neomano/locator.dart';
import 'package:neomano/presentation/viewmodels/device_list_viewmodel.dart';
import 'package:neomano/presentation/views/control_device_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';

class DeviceListPage extends StatefulWidget {
  static const routeName = 'DeviceListPage';

  const DeviceListPage({Key key}) : super(key: key);

  @override
  _DeviceListPageState createState() {
    return _DeviceListPageState(getIt.get<DeviceListViewModel>());
  }
}

class _DeviceListPageState extends State<DeviceListPage> {
  final DeviceListViewModel deviceListViewModel;

  _DeviceListPageState(this.deviceListViewModel);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeviceListViewModel>.reactive(
          viewModelBuilder: () => deviceListViewModel,
          builder: (context, viewModel, child) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if(deviceListViewModel.isDeviceScanning)
                    stopScan();
                  else
                    startScan();
                },
                child: Text(deviceListViewModel.isDeviceScanning ? 'STOP' : 'START'),
              ),
              appBar: AppBar(title: Text(DeviceListPage.routeName)),
              body: Stack(
                children: [
                  ListView.separated(
                      itemBuilder: (context, index) {
                        return ListTile(
                            onTap: () {
                              _onDeviceSelected(viewModel.foundDevices[index]);
                            },
                            title: Text(
                              viewModel.foundDevices[index].toString(),
                              style: TextStyle(color: Colors.black),
                            ));
                      },
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: viewModel.foundDevices.length),
                  if (deviceListViewModel.isDeviceScanning)
                    Center(child: CircularProgressIndicator())
                ],
              ),
            );
          });
  }

  Future<void> startScan() async {
    // Map<Permission, PermissionStatus> statuses =
    await [
      Permission.location,
    ].request();

    if (await Permission.location.isGranted)
      await deviceListViewModel.startScan();
    else if (await Permission.location.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> stopScan() async {
    await deviceListViewModel.stopScan();
  }

  _onDeviceSelected(Device device) async {
    stopScan();
    try {
      if (await deviceListViewModel.connectDevice(device)) {
        Navigator.of(context)
            .pushNamed(ControlDevicePage.routeName, arguments: device);
      }
    } catch (e, st) {
      logger.e('Failed to connect device', e, st);
    }
  }
}
