import 'dart:async';

import 'package:control_protocol/control_protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/system_wifi.dart';
import 'package:wave_desktop_installer/data/translator.dart';
import 'package:wave_desktop_installer/domain/repository/socket_repository.dart';
import 'package:wave_desktop_installer/feature/pages/camera/camera_event.dart';
import 'package:wave_desktop_installer/feature/pages/camera/camera_state.dart';
import 'package:wave_desktop_installer/main.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/rx/arc_subject.dart';

@injectable
class CameraViewModel {
  CameraViewModel(this._socketRepository, this._wifiScanWindows);

  final SocketRepository _socketRepository;
  final SystemWifiUtils _wifiScanWindows;

  final cameraUiEvent = ArcSubject<CameraEvent>();
  final cameraUiState = ArcSubject<CameraUiState>();

  void startServer() {
    _socketRepository.startServer(_subscribeToMessages);
  }

  void stopServer() {
    _socketRepository.stopServer();
  }

  void checkConnection() async {
    bool isConnect = await _wifiScanWindows.isDesiredSsidConnected('WAVE');
    Log.d('isConnect => $isConnect');
    // if (isConnect) {
    //   cameraUiEvent.val = const CameraConnected();
    // } else {
    //   cameraUiEvent.val = const CameraNotConnected();
    // }

    cameraUiEvent.val = const CameraConnected();
  }

  Future<void> _subscribeToMessages() async {
    final socket = _socketRepository.getSocket;

    if (socket == null) {
      cameraUiEvent.val = const CameraNotConnected();
      return;
    }

    socket.onOpen((fn) {
      realLog.info('[socket connected] ${socket.id}');
    });
    socket.onClose((close) {
      realLog.info('[socket disconnect] ${socket.id}');
    });

    socket.onMessage((data, id) {
      try {
        String parseResponse = String.fromCharCodes(data);
        String content = parseResponse.replaceAll(', ', ',');
        final values = content.split(' ').skip(1).toList();

        if (content.startsWith(heartBeatPrefix)) {
          final heartBeatInfo = values[0].split(',');
          final response = WaveSensorHeartBeatResponse(
            timeStamp: heartBeatInfo[0],
            batteryStatus: heartBeatInfo[1],
            sleepStatus: heartBeatInfo[2],
            temperature: heartBeatInfo[3],
            pitchReal: heartBeatInfo[4],
            doorMode: heartBeatInfo[5],
            rollReal: heartBeatInfo[6],
            rollSticky: heartBeatInfo[7],
            rfStatus: heartBeatInfo[8],
            putStatus: heartBeatInfo[9],
          );

          cameraUiState.val = CameraUiState(heartbeat: response.toDomain());
        }
        realLog.info('from client Message => $parseResponse');
      } catch (e) {
        realLog.info('from client Message parse error => $data');
      }
    });
  }

  void dispose() {
    realLog.info('[stopServer]');
    cameraUiEvent.close();
    cameraUiState.close();
    stopServer();
  }
}
