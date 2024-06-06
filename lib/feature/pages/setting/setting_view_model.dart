import 'dart:async';

import 'package:control_protocol/control_protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/translator.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_state.dart';
import 'package:wave_desktop_installer/utils/rx/arc_subject.dart';

@injectable
class SettingViewModel {
  SettingViewModel(this._wifiRepository);

  final WifiRepository _wifiRepository;

  final settingUiState = ArcSubject<SettingUiState>();
  StreamSubscription<WaveSensorResponse>? _subscription;

  Future<void> subscribeToMessages() async {
    _subscription ??= _wifiRepository.responseMessage.listen((response) {
      if (response is WaveSensorHeartBeatResponse) {
        settingUiState.val = SettingUiState(heartbeat: response.toDomain());
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
