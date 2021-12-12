import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:neomano/data/datasources/device/device_datasource.dart';
import 'package:neomano/data/repositories/device_repository_impl.dart';
import 'package:neomano/domain/repositories/device_repository.dart';
import 'package:neomano/domain/usecases/control_device_usecase.dart';
import 'package:neomano/domain/usecases/search_device_usecase.dart';
import 'package:neomano/presentation/viewmodels/control_device_viewmodel.dart';
import 'package:neomano/presentation/viewmodels/device_list_viewmodel.dart';

import 'data/datasources/local/device_local_datasource.dart';
import 'domain/usecases/connect_device_usecase.dart';

final getIt = GetIt.instance;

void setupLocator() {
  //Data
  getIt.registerSingleton<DeviceDataSource>(DeviceDataSourceImpl(Duration(seconds: 5)));
  getIt.registerFactory<DeviceLocalDataSource>(
      () => DeviceLocalDataSourceImpl());
  getIt.registerFactory<DeviceRepository>(() => DeviceRepositoryImpl(
      getIt.get<DeviceDataSource>(), getIt.get<DeviceLocalDataSource>()));
  //Domain
  getIt.registerFactory<SearchDeviceUserCase>(
      () => SearchDeviceUserCase(getIt.get<DeviceRepository>()));
  getIt.registerFactory<ConnectDeviceUserCase>(
      () => ConnectDeviceUserCase(getIt.get<DeviceRepository>()));
  getIt.registerFactory<ControlDeviceUseCase>(
          () => ControlDeviceUseCase(getIt.get<DeviceRepository>()));
  //Presentation
  getIt.registerFactory<DeviceListViewModel>(() => DeviceListViewModel(
      getIt.get<SearchDeviceUserCase>(), getIt.get<ConnectDeviceUserCase>()));
  getIt.registerFactory<ControlDeviceViewModel>(() => ControlDeviceViewModel(
      getIt.get<ControlDeviceUseCase>(), getIt.get<ConnectDeviceUserCase>()));
}

var logger = Logger(
  printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true // Should each log print contain a timestamp
      ),
);
