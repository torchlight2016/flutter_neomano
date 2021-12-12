class Device {
  final String name;
  final String identifier;
  final String uuid;
  dynamic peripheral;

  Device(this.name, this.identifier, this.uuid,this.peripheral);

  @override
  String toString() {
    return 'Device{name: $name, identifier: $identifier, uuid: $uuid}';
  }
}