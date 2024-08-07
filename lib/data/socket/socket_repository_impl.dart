import 'dart:collection';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/socket/wave_socket.dart';
import 'package:wave_desktop_installer/domain/repository/socket_repository.dart';
import 'package:wave_desktop_installer/utils/constant.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';


typedef VoidCallback = void Function();


@LazySingleton(as: SocketRepository)
class SocketRepositoryImpl extends SocketRepository {
  ServerSocket? _server;
  WaveSocket? _getSocket;

  final Map<String, HashSet<WaveSocket>> _rooms = <String, HashSet<WaveSocket>>{};
  final HashSet<WaveSocket> _sockets = HashSet<WaveSocket>();

  @override
  Future<void> stopServer() async {
    await Future.delayed(Duration.zero);
    await _server?.close();
  }

  @override
  WaveSocket? get getSocket => _getSocket;

  @override
  Future<void> startServer(VoidCallback fn) async {
      _server = await ServerSocket.bind(Const.hostname, Const.port);
      Log.d('Server started on: ${_server!.address}:${_server!.port}.');
      try {
        _server?.listen((Socket socket) {
          Log.d('New TCP client ${socket.address.address}:${socket.port} connected. hashcode => ${socket.hashCode}');
          _getSocket = WaveSocket.fromRaw(socket, _rooms, _sockets);
          fn();
        });
      } on SocketException catch (ex) {
        Log.d('SocketException ${ex.message}');
      }
  }
}