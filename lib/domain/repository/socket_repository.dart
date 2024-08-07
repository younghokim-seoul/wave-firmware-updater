




import 'package:wave_desktop_installer/data/socket/wave_socket.dart';

typedef VoidCallback = void Function();


abstract class SocketRepository{
  Future<void> startServer(VoidCallback fn);
  Future<void> stopServer();
  WaveSocket? get getSocket;
}