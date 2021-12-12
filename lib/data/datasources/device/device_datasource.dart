import 'dart:async';
import 'dart:typed_data';

import 'package:crclib/catalog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:neomano/data/mappers/device_mapper.dart';
import 'package:neomano/domain/entities/device.dart';
import 'package:neomano/domain/usecases/control_device_usecase.dart';
import 'package:neomano/locator.dart';
import 'package:neomano/utils/extension/int_extension.dart';

abstract class DeviceDataSource {
  Future<void> startScan(void onData(Device device));
  Future<void> stopScan();
  Future<bool> connectDevice(Device device);
  Future<void> disconnectDevice();
  Future<void> controlDevice(ControlDeviceParam param);
}

class DeviceDataSourceImpl extends DeviceDataSource {
  static const serviceUUID = 'xxxxxx-xxxxx-xxxx-xxxx-F5E7A7E43008';
  static const writeUUID = 'xxxxxx-xxxx-xxxx-xxxx-F5E7A7E43008';
  static const notificationUUID = 'xxxxx-xxxxx-xxxx-xxxxx-F5E7A7E43008';

  final BleManager bleManager = BleManager();
  final Duration duration;
  Device _connectedDevice;

  DeviceDataSourceImpl(this.duration){
    bleManager.createClient();
  }

  @override
  Future<void> startScan(onData(Device device)) async {
    bleManager.startPeripheralScan().listen((event) {
      var text =
          '${event.peripheral.toString()} \n ${event.advertisementData?.serviceUuids?.first}';
      logger.i(text);
      onData(DeviceMapper.mapperToDevice(event));
    }).onError((error){
      logger.e('[startScan]',error);
    });

    // await Future.delayed(duration)
    //     .then((value) => bleManager.stopPeripheralScan());
  }

  @override
  Future<void> stopScan() async => await bleManager.stopPeripheralScan();


  @override
  Future<bool> connectDevice(Device device) async {
    _connectedDevice = null;
    if (device.peripheral is Peripheral) {
      Peripheral peripheral = device.peripheral;
      peripheral
          .observeConnectionState(
              emitCurrentValue: true, completeOnDisconnect: true)
          .listen((connectionState) {
        logger.i(
            "Peripheral ${device.peripheral.identifier} connection state is $connectionState");
      });

      if (await peripheral.isConnected()) {
        return true;
      }
      await peripheral.connect(timeout: Duration(seconds: 3));
      await peripheral.discoverAllServicesAndCharacteristics();
      var isConnected = await peripheral.isConnected();
      if (isConnected) {
        _connectedDevice = device;
      }
      return await Future.value(isConnected);
    }

    return Future.value(false);
  }

  Future<void> disconnectDevice() async {
    if(_connectedDevice!=null){
      if(_connectedDevice.peripheral is Peripheral){
        Peripheral peripheral = _connectedDevice.peripheral;
        peripheral.disconnectOrCancelConnection();
      }
    }
  }

  Future<void> controlDevice(ControlDeviceParam param) async {
    if (_connectedDevice.peripheral is Peripheral) {
      Peripheral peripheral = _connectedDevice.peripheral;
      await peripheral.writeCharacteristic(
          serviceUUID, writeUUID, _makePacket(param), false);
    }
  }

  ///direction grip:0, release:1
  _makePacket(ControlDeviceParam param) {
    var header = 0xFA;
    var id = 0;
    List<int> payload = [];

    switch (param.action) {
      case DeviceAction.start:
        id = PacketTypeId.sensorStart;
        int direction;
        switch (param.direction) {
          case DeviceDirection.grip:
            direction = 0;
            break;
          case DeviceDirection.release:
            direction = 1;
            break;
        }
        payload = [direction, param.speed];
        break;
      case DeviceAction.stop:
        id = PacketTypeId.sensorStop;
        break;
    }
    var length = payload.length;

    var crcValue = Crc16Ccitt().convert(payload).toString();
    var checkSum = int.parse(crcValue).convertToByte(2, Endian.little);

    var packet = <int>[header, id, length, ...payload, ...checkSum.toList()];
    if (kDebugMode)
      logger.d(
          '[makePacket]${packet.map((e) => e.toRadixString(16)).toList().toString()}');
    return Uint8List.fromList(packet);
  }
}

abstract class PacketTypeId {
  static const sensorStart = 0x03;
  static const sensorStop = 0x04;
}
