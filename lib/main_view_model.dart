import 'dart:async';

import 'package:control_protocol/control_protocol.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:tuple/tuple.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';
import 'package:wave_desktop_installer/data/fwupd/fwupd_service.dart';
import 'package:wave_desktop_installer/domain/repository/patch_repository.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/main.dart';
import 'package:wave_desktop_installer/main_state.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:wave_desktop_installer/utils/rx/arc_subject.dart';

@lazySingleton
class MainViewModel {
  MainViewModel(this._wifiRepository, this._fwupdService);

  final WifiRepository _wifiRepository;
  final FwupdService _fwupdService;

  StreamSubscription<WaveSensorResponse>? _subscription;

  final navigateUiEvent = ArcSubject<MainViewEvent>();
  final mainUiState = ArcSubject<MainUiState>(seed: MainUiState.initial());
  final versionState = ArcSubject<Tuple3<int, int, bool>>(seed: const Tuple3(-1, -1, false));

  Future<void> subscribeToMessages() async {
    _subscription ??= _wifiRepository.responseMessage.listen((response) async {
      if (response is WaveSensorHeartBeatResponse) {
        MainUiState state = mainUiState.val;
        mainUiState.val = state.copyWith(batteryLevel: response.batteryStatus);
      }

      if (response is FirmwareVersionResponse) {
        try {
          final versionConfig = await _fwupdService.readConfig();

          realLog.info('[Red dot Check] current versionConfig $versionConfig');

          if (versionConfig.isNullOrEmpty) {
            return;
          }

          final serverVersion = int.parse(versionConfig.replaceAll('.', ''));
          final deviceVersion = int.parse(response.verCode);
          final isAvailableUpdate = serverVersion > deviceVersion;

          realLog.info('[Red dot Check]  serverVersion: $serverVersion, deviceVersion: $deviceVersion');
          versionState.val = Tuple3(serverVersion, deviceVersion, isAvailableUpdate);
        } catch (e) {
          Log.e("from remote error: $e");
        }
      }
    });

    _wifiRepository.statuses.listen((event) {
      if (event.item2 == ConnectionStatus.disconnected) {
        mainUiState.val = MainUiState.initial();
        versionState.val = const Tuple3(-1, -1, false);
      }
    });
  }

  void dispose() async {
    mainUiState.close();
    navigateUiEvent.close();
    _subscription?.cancel();
    _subscription = null;
  }

  void navigateToConnectionPage() {
    navigateUiEvent.val = const MoveToConnectionPageEvent();
  }

  void showCaption(bool isShow) {
    navigateUiEvent.val = ShowCaptionEvent(isShow: isShow);
  }
}

sealed class MainViewEvent extends Equatable {
  const MainViewEvent();

  @override
  List<Object?> get props => [];
}

class MoveToConnectionPageEvent extends MainViewEvent {
  const MoveToConnectionPageEvent();

  @override
  List<Object?> get props => [];
}

class ShowCaptionEvent extends MainViewEvent {
  const ShowCaptionEvent({required this.isShow});

  final bool isShow;

  @override
  List<Object?> get props => [isShow];
}
