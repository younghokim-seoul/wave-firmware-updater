import 'dart:async';

import 'package:control_protocol/control_protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';
import 'package:wave_desktop_installer/data/translator.dart';
import 'package:wave_desktop_installer/domain/repository/bluetooth_repository.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_event.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_state.dart';
import 'package:wave_desktop_installer/main.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/rx/arc_subject.dart';

@injectable
class SettingViewModel {
  SettingViewModel(this._wifiRepository);

  final WifiRepository _wifiRepository;

  final settingUiEvent = ArcSubject<SettingEvent>();
  final settingUiState = ArcSubject<SettingUiState>();
  StreamSubscription<WaveSensorResponse>? _subscription;
  StreamSubscription? _statusesSubscription;

  Future<void> subscribeToStatuses() async {
    _wifiRepository.setRetryConnectMode(false);
    _statusesSubscription ??= _wifiRepository.statuses.listen(
      (state) {
        realLog.info("[SettingViewModel] Connection Callback $state");
        if (state.item2 == ConnectionStatus.disconnected) {
          settingUiEvent.val = const DeviceNotConnected();
        } else {
          settingUiEvent.val = const DeviceConnected();
        }
      },
    );
  }

  Future<void> _unsubscribeSubscription() async {
    await _statusesSubscription?.cancel();
    _statusesSubscription = null;
  }

  void checkConnection() {
    if (_wifiRepository.isClosed) {
      settingUiEvent.val = const DeviceNotConnected();
    } else {
      settingUiEvent.val = const CameraLoading();
    }
  }

  Future<void> subscribeToMessages() async {
    _subscription ??= _wifiRepository.responseMessage.listen((response) {
      if (response is WaveSensorHeartBeatResponse) {
        settingUiState.val = SettingUiState(heartbeat: response.toDomain());
      }
    });
  }

  void dispose() {
    _unsubscribeSubscription();
    settingUiEvent.close();
    _subscription?.cancel();
    _subscription = null;
  }
}
