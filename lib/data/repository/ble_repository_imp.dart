import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/domain/repository/bluetooth_repository.dart';



@LazySingleton(as: BluetoothRepository)
class BleRepositoryImp extends BluetoothRepository {
  @override
  Future<void> connect(Map<String, dynamic> request) {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect(Map<String, dynamic> request) {
    // TODO: implement disconnect
    throw UnimplementedError();
  }

}
