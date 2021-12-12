import 'package:neomano/domain/repositories/device_repository.dart';
import 'package:neomano/domain/usecases/usecase.dart';

class SearchDeviceUserCase extends UseCase<void,SearchDeviceParam>{
  final DeviceRepository _deviceRepository;

  SearchDeviceUserCase(this._deviceRepository);

  @override
  Future<void> start([SearchDeviceParam param]) async {
    if(param.stop == true){
      _deviceRepository.stopScan();
    }else {
      _deviceRepository.startScan(param.onData);
    }
  }
}

class SearchDeviceParam{
  final Function onData;
  final bool stop;
  SearchDeviceParam({this.onData,this.stop=false});

}