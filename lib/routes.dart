import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:neomano/presentation/views/control_device_page.dart';
import 'package:neomano/presentation/views/device_list_page.dart';

Route<dynamic> onGenerateRoute(RouteSettings s) {
  switch (s.name) {
    case DeviceListPage.routeName:
      return MaterialPageRoute(
        settings: s,
        builder: (context) => DeviceListPage(),
      );
    case ControlDevicePage.routeName:
      return MaterialPageRoute(
          settings: s,
          builder: (context) => ControlDevicePage(device: s.arguments));
  }
  return null;
}
